-- Yippo: wekelijks toernooi (beste Tijdrace van de week) en league-kampioenen
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- Het toernooi is een eigen spel, los van de Tijdrace: de scores staan in een eigen tabel (yippo_tour_scores).
-- Eerst yippo.sql draaien. (tijdrace.sql is voor het toernooi niet nodig.)
-- p_week is altijd de maandag van de week; de week loopt van die maandag t/m zondag.

create table if not exists yippo_tour_scores (
  day        date        not null,
  player_id  uuid        not null references auth.users(id) on delete cascade,   -- bij account verwijderen verdwijnt de score mee
  name       text        not null check (char_length(name) between 1 and 20),
  score      int         not null check (score between 0 and 100000),
  updated_at timestamptz not null default now(),
  primary key (day, player_id)
);
create index if not exists yippo_tour_day_score on yippo_tour_scores (day, score desc);
alter table yippo_tour_scores enable row level security;   -- geen directe toegang, alleen via de functies hieronder

-- Score van een toernooi-ronde opslaan (houdt de hoogste score van die dag). Geeft de plek in de week terug.
create or replace function yippo_tour_submit(p_day date, p_name text, p_score int)
returns table (rank bigint, total bigint)
language plpgsql security definer set search_path = public as $$
declare
  v_uid   uuid := auth.uid();
  v_name  text := left(btrim(coalesce(p_name, '')), 20);
  v_today date := (now() at time zone 'utc')::date;
  v_week  date;
  v_best  int;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if v_name = '' then raise exception 'bad_name'; end if;
  if p_day is null or p_day < v_today - 1 or p_day > v_today + 1 then raise exception 'bad_day'; end if;
  if p_score is null or p_score < 0 or p_score > 100000 then raise exception 'bad_score'; end if;

  insert into yippo_tour_scores as s (day, player_id, name, score)
  values (p_day, v_uid, v_name, p_score)
  on conflict (day, player_id) do update
    set score = greatest(s.score, excluded.score), name = excluded.name, updated_at = now();

  v_week := date_trunc('week', p_day)::date;   -- maandag van die week
  select max(s.score) into v_best from yippo_tour_scores s
    where s.player_id = v_uid and s.day between v_week and v_week + 6;
  return query
    select (select count(*) + 1 from (select max(s.score) as sc from yippo_tour_scores s
              where s.day between v_week and v_week + 6 group by s.player_id) x where x.sc > v_best),
           (select count(distinct s.player_id) from yippo_tour_scores s where s.day between v_week and v_week + 6);
end $$;

-- Weekranglijst wereldwijd: beste Tijdrace-score van elke speler in die week.
create or replace function yippo_week_global(p_week date, p_limit int default 50)
returns table (rank bigint, name text, score int, player_id uuid, total bigint)
language sql security definer set search_path = public stable as $$
  with b as (
    select s.player_id, max(s.score) as score, max(s.updated_at) as t,
           (array_agg(s.name order by s.updated_at desc))[1] as name
    from yippo_tour_scores s
    where s.day between p_week and p_week + 6
    group by s.player_id
  )
  select rank() over (order by b.score desc, b.t), b.name, b.score, b.player_id, count(*) over ()
  from b
  order by b.score desc, b.t
  limit least(greatest(coalesce(p_limit, 50), 1), 100)
$$;

-- Mijn eigen plek in de weekranglijst (geen rij als je die week niet hebt meegedaan).
create or replace function yippo_week_me(p_week date)
returns table (rank bigint, total bigint, score int)
language sql security definer set search_path = public stable as $$
  with b as (
    select s.player_id, max(s.score) as score, max(s.updated_at) as t
    from yippo_tour_scores s
    where s.day between p_week and p_week + 6
    group by s.player_id
  ), r as (
    select b.player_id, b.score, rank() over (order by b.score desc, b.t) as rk, count(*) over () as n from b
  )
  select r.rk, r.n, r.score from r where r.player_id = auth.uid()
$$;

-- Stand van een league in een toernooiweek (wie de code kent, mag kijken). Leden zonder score staan er met 0 bij.
create or replace function yippo_league_week(p_code text, p_week date)
returns table (rank bigint, name text, score int, player_id uuid, total bigint)
language sql security definer set search_path = public stable as $$
  with m as (
    select m.player_id, m.name from yippo_members m where m.code = upper(btrim(coalesce(p_code, '')))
  ), b as (
    select m.player_id, m.name, coalesce(max(s.score), 0) as score, max(s.updated_at) as t
    from m left join yippo_tour_scores s on s.player_id = m.player_id and s.day between p_week and p_week + 6
    group by m.player_id, m.name
  )
  select rank() over (order by b.score desc, b.t nulls last), b.name, b.score, b.player_id, count(*) over ()
  from b
  order by b.score desc, b.t nulls last, b.name
$$;

revoke all on function yippo_tour_submit(date, text, int), yippo_week_global(date, int), yippo_week_me(date), yippo_league_week(text, date) from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on function yippo_tour_submit(date, text, int), yippo_week_me(date) from anon;
    grant execute on function yippo_week_global(date, int), yippo_league_week(text, date) to anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function yippo_tour_submit(date, text, int), yippo_week_global(date, int), yippo_week_me(date), yippo_league_week(text, date) to authenticated;
  end if;
end $$;
