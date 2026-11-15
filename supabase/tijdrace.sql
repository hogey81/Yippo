-- Yippo: scorebord voor de Tijdrace (60 seconden, zoveel mogelijk punten)
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- Eerst yippo.sql moet al gedraaid zijn. Alle namen beginnen met "yippo_".

create table if not exists yippo_race_scores (
  day        date        not null,
  player_id  uuid        not null references auth.users(id) on delete cascade,   -- bij account verwijderen verdwijnt de score mee
  name       text        not null check (char_length(name) between 1 and 20),
  score      int         not null check (score between 0 and 100000),
  updated_at timestamptz not null default now(),
  primary key (day, player_id)
);
create index if not exists yippo_race_day_score on yippo_race_scores (day, score desc);
alter table yippo_race_scores enable row level security;   -- geen directe toegang, alleen via de functies hieronder

create or replace function yippo_race_submit(p_day date, p_name text, p_score int)
returns table (rank bigint, total bigint)
language plpgsql security definer set search_path = public as $$
declare
  v_uid   uuid := auth.uid();
  v_name  text := left(btrim(coalesce(p_name, '')), 20);
  v_today date := (now() at time zone 'utc')::date;
  v_best  int;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if v_name = '' then raise exception 'bad_name'; end if;
  if p_day is null or p_day < v_today - 1 or p_day > v_today + 1 then raise exception 'bad_day'; end if;
  if p_score is null or p_score < 0 or p_score > 100000 then raise exception 'bad_score'; end if;

  insert into yippo_race_scores as s (day, player_id, name, score)
  values (p_day, v_uid, v_name, p_score)
  on conflict (day, player_id) do update
    set score = greatest(s.score, excluded.score), name = excluded.name, updated_at = now();

  select s.score into v_best from yippo_race_scores s where s.day = p_day and s.player_id = v_uid;
  return query
    select (select count(*) + 1 from yippo_race_scores s where s.day = p_day and s.score > v_best),
           (select count(*) from yippo_race_scores s where s.day = p_day);
end $$;

create or replace function yippo_race_global(p_day date, p_limit int default 50)
returns table (rank bigint, name text, score int, player_id uuid, total bigint)
language sql security definer set search_path = public stable as $$
  select rank() over (order by s.score desc, s.updated_at), s.name, s.score, s.player_id, count(*) over ()
  from yippo_race_scores s
  where s.day = p_day
  order by s.score desc, s.updated_at
  limit least(greatest(coalesce(p_limit, 50), 1), 100)
$$;

revoke all on function yippo_race_submit(date, text, int), yippo_race_global(date, int) from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on function yippo_race_submit(date, text, int) from anon;
    grant execute on function yippo_race_global(date, int) to anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function yippo_race_submit(date, text, int), yippo_race_global(date, int) to authenticated;
  end if;
end $$;
