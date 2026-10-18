-- Yippo: wereldwijd scorebord + leagues
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run.
-- Alle namen beginnen met "yippo_", dus het is veilig om een bestaand Supabase-project te delen.

-- ========== Tabellen ==========
create table if not exists yippo_scores (
  day        date        not null,
  player_id  uuid        not null,
  name       text        not null check (char_length(name) between 1 and 20),
  score      int         not null check (score between 0 and 50000),
  updated_at timestamptz not null default now(),
  primary key (day, player_id)
);
create index if not exists yippo_scores_day_score on yippo_scores (day, score desc);

create table if not exists yippo_leagues (
  code       text primary key check (code ~ '^[A-Z0-9]{5}$'),
  name       text not null check (char_length(name) between 1 and 24),
  created_at timestamptz not null default now()
);

create table if not exists yippo_members (
  code      text not null references yippo_leagues (code) on delete cascade,
  player_id uuid not null,
  name      text not null check (char_length(name) between 1 and 20),
  joined_at timestamptz not null default now(),
  primary key (code, player_id)
);
create index if not exists yippo_members_player on yippo_members (player_id);

-- Niemand mag de tabellen rechtstreeks lezen of schrijven; alles gaat via de functies hieronder.
alter table yippo_scores  enable row level security;
alter table yippo_leagues enable row level security;
alter table yippo_members enable row level security;
revoke all on yippo_scores, yippo_leagues, yippo_members from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on yippo_scores, yippo_leagues, yippo_members from anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    revoke all on yippo_scores, yippo_leagues, yippo_members from authenticated;
  end if;
end $$;

-- ========== Functies ==========

-- Score opslaan (houdt de hoogste score van die dag). Geeft de plek in het wereldwijde scorebord terug.
create or replace function yippo_submit_score(p_day date, p_player uuid, p_name text, p_score int)
returns table (rank bigint, total bigint)
language plpgsql security definer set search_path = public as $$
declare
  v_name  text := left(btrim(coalesce(p_name, '')), 20);
  v_today date := (now() at time zone 'utc')::date;
  v_best  int;
begin
  if p_player is null then raise exception 'bad_player'; end if;
  if v_name = '' then raise exception 'bad_name'; end if;
  if p_day is null or p_day < v_today - 1 or p_day > v_today + 1 then raise exception 'bad_day'; end if;
  if p_score is null or p_score < 0 or p_score > 50000 then raise exception 'bad_score'; end if;

  insert into yippo_scores as s (day, player_id, name, score)
  values (p_day, p_player, v_name, p_score)
  on conflict (day, player_id) do update
    set score = greatest(s.score, excluded.score), name = excluded.name, updated_at = now();

  update yippo_members set name = v_name where player_id = p_player and name <> v_name;

  select s.score into v_best from yippo_scores s where s.day = p_day and s.player_id = p_player;
  return query
    select (select count(*) + 1 from yippo_scores s where s.day = p_day and s.score > v_best),
           (select count(*) from yippo_scores s where s.day = p_day);
end $$;

-- Wereldwijd scorebord van één dag.
create or replace function yippo_global(p_day date, p_limit int default 50)
returns table (rank bigint, name text, score int, player_id uuid, total bigint)
language sql security definer set search_path = public stable as $$
  select rank() over (order by s.score desc, s.updated_at), s.name, s.score, s.player_id, count(*) over ()
  from yippo_scores s
  where s.day = p_day
  order by s.score desc, s.updated_at
  limit least(greatest(coalesce(p_limit, 50), 1), 100)
$$;

-- Nieuwe league maken. Geeft de code van 5 tekens terug.
create or replace function yippo_create_league(p_name text, p_player uuid, p_player_name text)
returns text
language plpgsql security definer set search_path = public as $$
declare
  v_name  text := left(btrim(coalesce(p_name, '')), 24);
  v_pname text := left(btrim(coalesce(p_player_name, '')), 20);
  v_alpha constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code  text;
  i int;
begin
  if p_player is null then raise exception 'bad_player'; end if;
  if v_name = '' or v_pname = '' then raise exception 'bad_name'; end if;
  if (select count(*) from yippo_members where player_id = p_player) >= 10 then raise exception 'too_many'; end if;
  loop
    v_code := '';
    for i in 1..5 loop
      v_code := v_code || substr(v_alpha, 1 + floor(random() * length(v_alpha))::int, 1);
    end loop;
    exit when not exists (select 1 from yippo_leagues where code = v_code);
  end loop;
  insert into yippo_leagues (code, name) values (v_code, v_name);
  insert into yippo_members (code, player_id, name) values (v_code, p_player, v_pname);
  return v_code;
end $$;

-- Meedoen met een league via de code. Geeft de naam van de league terug.
create or replace function yippo_join_league(p_code text, p_player uuid, p_player_name text)
returns text
language plpgsql security definer set search_path = public as $$
declare
  v_code  text := upper(btrim(coalesce(p_code, '')));
  v_pname text := left(btrim(coalesce(p_player_name, '')), 20);
  v_lname text;
begin
  if p_player is null then raise exception 'bad_player'; end if;
  if v_pname = '' then raise exception 'bad_name'; end if;
  select name into v_lname from yippo_leagues where code = v_code;
  if v_lname is null then raise exception 'league_not_found'; end if;
  if not exists (select 1 from yippo_members where code = v_code and player_id = p_player) then
    if (select count(*) from yippo_members where code = v_code) >= 50 then raise exception 'league_full'; end if;
    if (select count(*) from yippo_members where player_id = p_player) >= 10 then raise exception 'too_many'; end if;
  end if;
  insert into yippo_members (code, player_id, name) values (v_code, p_player, v_pname)
  on conflict (code, player_id) do update set name = excluded.name;
  return v_lname;
end $$;

-- Stand van een league: score van vandaag en totaal van de laatste 7 dagen per speler.
create or replace function yippo_league(p_code text, p_day date)
returns table (league_name text, player_id uuid, name text, today int, week int)
language sql security definer set search_path = public stable as $$
  select l.name, m.player_id, m.name,
         max(s.score) filter (where s.day = p_day)::int,
         coalesce(sum(s.score) filter (where s.day between p_day - 6 and p_day), 0)::int
  from yippo_leagues l
  join yippo_members m on m.code = l.code
  left join yippo_scores s on s.player_id = m.player_id and s.day between p_day - 6 and p_day
  where l.code = upper(btrim(coalesce(p_code, '')))
  group by l.name, m.player_id, m.name
  order by 5 desc, 4 desc nulls last, m.name
$$;

-- Een league verlaten.
create or replace function yippo_leave_league(p_code text, p_player uuid)
returns void
language sql security definer set search_path = public as $$
  delete from yippo_members where code = upper(btrim(coalesce(p_code, ''))) and player_id = p_player;
  delete from yippo_leagues l where l.code = upper(btrim(coalesce(p_code, ''))) and not exists (select 1 from yippo_members m where m.code = l.code);
$$;

revoke all on function yippo_submit_score(date, uuid, text, int), yippo_global(date, int),
  yippo_create_league(text, uuid, text), yippo_join_league(text, uuid, text),
  yippo_league(text, date), yippo_leave_league(text, uuid) from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    grant execute on function yippo_submit_score(date, uuid, text, int), yippo_global(date, int),
      yippo_create_league(text, uuid, text), yippo_join_league(text, uuid, text),
      yippo_league(text, date), yippo_leave_league(text, uuid) to anon, authenticated;
  end if;
end $$;
