-- Yippo: wereldwijd scorebord, leagues en voortgang in de cloud (versie 2: met accounts)
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run.
-- Het is veilig om het opnieuw te draaien, ook als je versie 1 al hebt gedraaid.
-- Alle namen beginnen met "yippo_", dus het raakt niets anders in je project.
--
-- Vooraf: zet in Supabase onder Authentication -> Sign In / Providers de optie
-- "Allow anonymous sign-ins" aan. Spelers krijgen dan automatisch een gastaccount.

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

-- Voortgang per account (levels, sterren, streak, leagues). Verdwijnt als het account wordt verwijderd.
create table if not exists yippo_profiles (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Niemand mag de tabellen rechtstreeks lezen of schrijven; alles gaat via de functies hieronder.
alter table yippo_scores   enable row level security;
alter table yippo_leagues  enable row level security;
alter table yippo_members  enable row level security;
alter table yippo_profiles enable row level security;
revoke all on yippo_scores, yippo_leagues, yippo_members, yippo_profiles from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on yippo_scores, yippo_leagues, yippo_members, yippo_profiles from anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    revoke all on yippo_scores, yippo_leagues, yippo_members, yippo_profiles from authenticated;
  end if;
end $$;

-- ========== Oude functies (versie 1, zonder inlog) weghalen ==========
drop function if exists yippo_submit_score(date, uuid, text, int);
drop function if exists yippo_create_league(text, uuid, text);
drop function if exists yippo_join_league(text, uuid, text);
drop function if exists yippo_leave_league(text, uuid);

-- ========== Functies ==========
-- Wie je bent komt uit je inlog (auth.uid()), niet uit iets dat de app zelf opgeeft.

-- Score opslaan (houdt de hoogste score van die dag). Geeft de plek in het wereldwijde scorebord terug.
create or replace function yippo_submit_score(p_day date, p_name text, p_score int)
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
  if p_score is null or p_score < 0 or p_score > 50000 then raise exception 'bad_score'; end if;

  insert into yippo_scores as s (day, player_id, name, score)
  values (p_day, v_uid, v_name, p_score)
  on conflict (day, player_id) do update
    set score = greatest(s.score, excluded.score), name = excluded.name, updated_at = now();

  update yippo_members set name = v_name where player_id = v_uid and name <> v_name;

  select s.score into v_best from yippo_scores s where s.day = p_day and s.player_id = v_uid;
  return query
    select (select count(*) + 1 from yippo_scores s where s.day = p_day and s.score > v_best),
           (select count(*) from yippo_scores s where s.day = p_day);
end $$;

-- Wereldwijd scorebord van één dag (openbaar leesbaar).
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
create or replace function yippo_create_league(p_name text, p_player_name text)
returns text
language plpgsql security definer set search_path = public as $$
declare
  v_uid   uuid := auth.uid();
  v_name  text := left(btrim(coalesce(p_name, '')), 24);
  v_pname text := left(btrim(coalesce(p_player_name, '')), 20);
  v_alpha constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code  text;
  i int;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if v_name = '' or v_pname = '' then raise exception 'bad_name'; end if;
  if (select count(*) from yippo_members where player_id = v_uid) >= 10 then raise exception 'too_many'; end if;
  loop
    v_code := '';
    for i in 1..5 loop
      v_code := v_code || substr(v_alpha, 1 + floor(random() * length(v_alpha))::int, 1);
    end loop;
    exit when not exists (select 1 from yippo_leagues where code = v_code);
  end loop;
  insert into yippo_leagues (code, name) values (v_code, v_name);
  insert into yippo_members (code, player_id, name) values (v_code, v_uid, v_pname);
  return v_code;
end $$;

-- Meedoen met een league via de code. Geeft de naam van de league terug.
create or replace function yippo_join_league(p_code text, p_player_name text)
returns text
language plpgsql security definer set search_path = public as $$
declare
  v_uid   uuid := auth.uid();
  v_code  text := upper(btrim(coalesce(p_code, '')));
  v_pname text := left(btrim(coalesce(p_player_name, '')), 20);
  v_lname text;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if v_pname = '' then raise exception 'bad_name'; end if;
  select name into v_lname from yippo_leagues where code = v_code;
  if v_lname is null then raise exception 'league_not_found'; end if;
  if not exists (select 1 from yippo_members where code = v_code and player_id = v_uid) then
    if (select count(*) from yippo_members where code = v_code) >= 50 then raise exception 'league_full'; end if;
    if (select count(*) from yippo_members where player_id = v_uid) >= 10 then raise exception 'too_many'; end if;
  end if;
  insert into yippo_members (code, player_id, name) values (v_code, v_uid, v_pname)
  on conflict (code, player_id) do update set name = excluded.name;
  return v_lname;
end $$;

-- Stand van een league (wie de code kent, mag kijken): score van vandaag en totaal van de laatste 7 dagen.
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

-- Een league verlaten (een lege league verdwijnt vanzelf).
create or replace function yippo_leave_league(p_code text)
returns void
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_code text := upper(btrim(coalesce(p_code, '')));
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  delete from yippo_members where code = v_code and player_id = v_uid;
  delete from yippo_leagues l where l.code = v_code and not exists (select 1 from yippo_members m where m.code = l.code);
end $$;

-- Voortgang bewaren en ophalen.
create or replace function yippo_save_progress(p_data jsonb)
returns void
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' or octet_length(p_data::text) > 30000 then raise exception 'bad_data'; end if;
  insert into yippo_profiles (user_id, data) values (v_uid, p_data)
  on conflict (user_id) do update set data = excluded.data, updated_at = now();
end $$;

create or replace function yippo_load_progress()
returns jsonb
language plpgsql security definer set search_path = public stable as $$
declare v_uid uuid := auth.uid(); v jsonb;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  select data into v from yippo_profiles where user_id = v_uid;
  return coalesce(v, '{}'::jsonb);
end $$;

-- Account en alle bijbehorende gegevens verwijderen (verplicht in de App Store en Play Store).
create or replace function yippo_delete_account()
returns void
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  delete from yippo_scores   where player_id = v_uid;
  delete from yippo_members  where player_id = v_uid;
  delete from yippo_leagues l where not exists (select 1 from yippo_members m where m.code = l.code);
  delete from yippo_profiles where user_id = v_uid;
  delete from auth.users     where id = v_uid;
end $$;

-- ========== Rechten ==========
-- Schrijven en eigen gegevens: alleen ingelogde spelers (ook gasten). Lezen van bord en league-stand: iedereen.
revoke all on function
  yippo_submit_score(date, text, int), yippo_global(date, int), yippo_create_league(text, text),
  yippo_join_league(text, text), yippo_league(text, date), yippo_leave_league(text),
  yippo_save_progress(jsonb), yippo_load_progress(), yippo_delete_account()
from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on function
      yippo_submit_score(date, text, int), yippo_create_league(text, text), yippo_join_league(text, text),
      yippo_leave_league(text), yippo_save_progress(jsonb), yippo_load_progress(), yippo_delete_account()
    from anon;
    grant execute on function yippo_global(date, int), yippo_league(text, date) to anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function
      yippo_submit_score(date, text, int), yippo_global(date, int), yippo_create_league(text, text),
      yippo_join_league(text, text), yippo_league(text, date), yippo_leave_league(text),
      yippo_save_progress(jsonb), yippo_load_progress(), yippo_delete_account()
    to authenticated;
  end if;
end $$;
