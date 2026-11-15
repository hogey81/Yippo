-- Yippo: wekelijks toernooi (beste Tijdrace van de week) en league-kampioenen
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- Eerst yippo.sql en tijdrace.sql draaien. Er komen geen nieuwe tabellen bij: alles komt uit yippo_race_scores.
-- p_week is altijd de maandag van de week; de week loopt van die maandag t/m zondag.

-- Weekranglijst wereldwijd: beste Tijdrace-score van elke speler in die week.
create or replace function yippo_week_global(p_week date, p_limit int default 50)
returns table (rank bigint, name text, score int, player_id uuid, total bigint)
language sql security definer set search_path = public stable as $$
  with b as (
    select s.player_id, max(s.score) as score, max(s.updated_at) as t,
           (array_agg(s.name order by s.updated_at desc))[1] as name
    from yippo_race_scores s
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
    from yippo_race_scores s
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
    from m left join yippo_race_scores s on s.player_id = m.player_id and s.day between p_week and p_week + 6
    group by m.player_id, m.name
  )
  select rank() over (order by b.score desc, b.t nulls last), b.name, b.score, b.player_id, count(*) over ()
  from b
  order by b.score desc, b.t nulls last, b.name
$$;

revoke all on function yippo_week_global(date, int), yippo_week_me(date), yippo_league_week(text, date) from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on function yippo_week_me(date) from anon;
    grant execute on function yippo_week_global(date, int), yippo_league_week(text, date) to anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function yippo_week_global(date, int), yippo_week_me(date), yippo_league_week(text, date) to authenticated;
  end if;
end $$;
