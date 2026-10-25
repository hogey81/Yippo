-- Yippo: beheerpagina (/beheer) met statistieken. Alleen admins kunnen de cijfers ophalen; de pagina zelf is openbaar maar leeg zonder toegang.
-- Plak dit bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- Pas daarna het e-mailadres hieronder aan als je met een ander adres wilt inloggen en draai het opnieuw.
--
-- Het geeft alleen totalen en tellingen terug (geen namen, e-mailadressen of scores per persoon).

create table if not exists yippo_admins (email text primary key);
alter table yippo_admins enable row level security;
revoke all on yippo_admins from public, anon, authenticated;

-- Wie mag de beheerpagina zien? (kleine letters)
insert into yippo_admins (email) values ('info@bestecamerakeuze.nl') on conflict do nothing;

create or replace function yippo_admin_stats()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
  r jsonb;
begin
  if auth.uid() is null or v_email = '' or not exists (select 1 from yippo_admins where email = v_email) then
    raise exception 'not_admin';
  end if;

  select jsonb_build_object(
    'generated',          now(),
    'accounts_total',     (select count(*) from auth.users),
    'accounts_guest',     (select count(*) from auth.users where is_anonymous),
    'accounts_email',     (select count(*) from auth.users where coalesce(email, '') <> ''),
    'profiles',           (select count(*) from yippo_profiles),
    'adults',             (select count(*) from yippo_profiles where data ->> 'age' = 'adult'),
    'children',           (select count(*) from yippo_profiles where data ->> 'age' = 'child'),
    'players_with_score', (select count(distinct player_id) from yippo_scores),
    'scores_total',       (select count(*) from yippo_scores),
    'leagues',            (select count(*) from yippo_leagues),
    'league_members',     (select count(*) from yippo_members),
    'active_1d',          (select count(*) from yippo_profiles where updated_at > now() - interval '1 day'),
    'active_7d',          (select count(*) from yippo_profiles where updated_at > now() - interval '7 days'),
    'active_30d',         (select count(*) from yippo_profiles where updated_at > now() - interval '30 days'),
    'new_1d',             (select count(*) from auth.users where created_at > now() - interval '1 day'),
    'new_7d',             (select count(*) from auth.users where created_at > now() - interval '7 days'),
    'new_30d',            (select count(*) from auth.users where created_at > now() - interval '30 days'),
    'daily', coalesce((
      select jsonb_agg(x order by x ->> 'day')
      from (
        select jsonb_build_object(
          'day',          d::date,
          'new_accounts', (select count(*) from auth.users u where u.created_at::date = d::date),
          'players',      (select count(distinct s.player_id) from yippo_scores s where s.day = d::date),
          'best',         (select max(s.score) from yippo_scores s where s.day = d::date)
        ) as x
        from generate_series(current_date - 29, current_date, interval '1 day') d
      ) t
    ), '[]'::jsonb),
    'worlds', coalesce((
      select jsonb_agg(jsonb_build_object('world', w, 'n', n) order by w)
      from (
        select case when (data ->> 'unlocked') ~ '^[0-9]+$' then ((data ->> 'unlocked')::int - 1) / 40 + 1 end as w, count(*) as n
        from yippo_profiles
        group by 1
      ) t
      where w is not null
    ), '[]'::jsonb)
  ) into r;
  return r;
end $$;

revoke all on function yippo_admin_stats() from public, anon;
grant execute on function yippo_admin_stats() to authenticated;
