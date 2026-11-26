-- Yippo: toernooi met bracket (kwalificatie, kwartfinale, halve finale, finale)
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- Eerst yippo.sql en toernooi.sql draaien (de scores van de kwalificatie staan in yippo_tour_scores).
--
-- Schema per week (maandag t/m zondag, tijden in Europe/Amsterdam):
--   ma-do  kwalificatie: speel zo vaak je wilt, je beste score telt. De beste 8 komen in de bracket.
--   vr     kwartfinale  (1-8, 4-5, 2-7, 3-6)       zo  finale
--   za     halve finale                            ma  uitslag en bekers (de volgende maandag)
--   Zijn er minder dan 8 spelers, dan krijgen de hoogst geplaatste spelers een bye (of de eerste ronde wordt overgeslagen).
--   Elke ronde speel je één keer 60 seconden op hetzelfde bord als je tegenstander. Meeste punten wint.
--   Gelijk: de hoogst geplaatste speler gaat door. Niet gespeeld: de tegenstander gaat door.
-- De bracket wordt "lui" opgebouwd: de eerste keer dat iemand de stand opvraagt na het einde van een ronde.
-- Het eerste bracket-toernooi is de week van maandag 23 november 2026.

create table if not exists yippo_bracket_meta (
  week       date primary key,
  size       int  not null,       -- 8, 4, 2 of 0 (te weinig spelers)
  qualifiers int  not null,
  created_at timestamptz not null default now()
);
create table if not exists yippo_bracket_matches (
  week   date not null,
  round  int  not null check (round between 1 and 3),   -- 1 kwartfinale, 2 halve finale, 3 finale
  slot   int  not null,
  p1 uuid, n1 text, seed1 int,
  p2 uuid, n2 text, seed2 int,                           -- p2 leeg = bye
  winner uuid,
  decided_at timestamptz,
  primary key (week, round, slot)
);
create table if not exists yippo_bracket_plays (
  week       date not null,
  round      int  not null,
  player_id  uuid not null,
  started_at timestamptz not null default now(),
  score      int check (score between 0 and 100000),
  primary key (week, round, player_id)
);
-- Alleen voor het testen: verschuift de klok van het toernooi (zie onderaan dit bestand).
create table if not exists yippo_test_clock (
  id    int primary key default 1 check (id = 1),
  shift interval not null default '0 seconds'
);
insert into yippo_test_clock (id) values (1) on conflict do nothing;

alter table yippo_bracket_meta    enable row level security;
alter table yippo_bracket_matches enable row level security;
alter table yippo_bracket_plays   enable row level security;
alter table yippo_test_clock      enable row level security;
revoke all on yippo_bracket_meta, yippo_bracket_matches, yippo_bracket_plays, yippo_test_clock from public;

create or replace function yippo_now() returns timestamptz
language sql stable as $$ select now() + coalesce((select shift from yippo_test_clock where id = 1), interval '0 seconds') $$;
create or replace function yippo_today() returns date
language sql stable as $$ select (yippo_now() at time zone 'Europe/Amsterdam')::date $$;

-- Bouwt de bracket en beslist afgelopen rondes (intern, niet voor de app).
create or replace function yippo_bracket_ensure(p_week date)
returns void
language plpgsql security definer set search_path = public as $$
declare
  v_d int; v_n int; v_size int; v_fr int; r int; k int; i int; a int; b int;
  m record; w uuid; s1 int; s2 int;
  v_ids uuid[]; v_names text[]; pairs int[];
begin
  if p_week < date '2026-11-23' then return; end if;
  v_d := yippo_today() - p_week;
  if v_d < 4 then return; end if;
  perform pg_advisory_xact_lock(hashtext('yippo_bracket_' || p_week::text));

  if not exists (select 1 from yippo_bracket_meta where week = p_week) then
    select count(*) into v_n from (
      select player_id from yippo_tour_scores where day between p_week and p_week + 3
      group by player_id having max(score) > 0) q;
    v_size := case when v_n >= 5 then 8 when v_n >= 3 then 4 when v_n = 2 then 2 else 0 end;
    insert into yippo_bracket_meta (week, size, qualifiers) values (p_week, v_size, v_n);
    if v_size > 0 then
      v_fr := case v_size when 8 then 1 when 4 then 2 else 3 end;
      select array_agg(player_id order by rk), array_agg(nm order by rk) into v_ids, v_names from (
        select player_id, nm, row_number() over (order by sc desc, t) rk from (
          select player_id, max(score) sc, max(updated_at) t, (array_agg(name order by updated_at desc))[1] nm
          from yippo_tour_scores where day between p_week and p_week + 3
          group by player_id having max(score) > 0) q) z
        where rk <= 8;
      pairs := case v_size when 8 then array[[1,8],[4,5],[2,7],[3,6]] when 4 then array[[1,4],[2,3]] else array[[1,2]] end;
      for i in 1 .. array_length(pairs, 1) loop
        a := pairs[i][1]; b := pairs[i][2];
        insert into yippo_bracket_matches (week, round, slot, p1, n1, seed1, p2, n2, seed2)
        values (p_week, v_fr, i, v_ids[a], v_names[a], a,
                case when b <= v_n then v_ids[b] end, case when b <= v_n then v_names[b] end, case when b <= v_n then b end);
      end loop;
    end if;
  end if;

  select size into v_size from yippo_bracket_meta where week = p_week;
  if v_size = 0 then return; end if;
  v_fr := case v_size when 8 then 1 when 4 then 2 else 3 end;

  for r in v_fr .. 3 loop
    exit when v_d <= 4 + (r - v_fr);   -- deze ronde is nog niet afgelopen
    for m in select * from yippo_bracket_matches where week = p_week and round = r and winner is null loop
      select score into s1 from yippo_bracket_plays where week = p_week and round = r and player_id = m.p1;
      select score into s2 from yippo_bracket_plays where week = p_week and round = r and player_id = m.p2;
      if m.p2 is null then w := m.p1;
      elsif coalesce(s1, -1) > coalesce(s2, -1) then w := m.p1;
      elsif coalesce(s2, -1) > coalesce(s1, -1) then w := m.p2;
      elsif m.seed1 < m.seed2 then w := m.p1;
      else w := m.p2; end if;
      update yippo_bracket_matches set winner = w, decided_at = yippo_now()
       where week = p_week and round = r and slot = m.slot;
    end loop;
    if r < 3 then
      for k in 1 .. (case r when 1 then 2 else 1 end) loop
        if not exists (select 1 from yippo_bracket_matches where week = p_week and round = r + 1 and slot = k) then
          insert into yippo_bracket_matches (week, round, slot, p1, n1, seed1, p2, n2, seed2)
          select p_week, r + 1, k, wa.w, wa.n, wa.sd, wb.w, wb.n, wb.sd
          from (select winner w, case when winner = p1 then n1 else n2 end n, case when winner = p1 then seed1 else seed2 end sd
                  from yippo_bracket_matches where week = p_week and round = r and slot = 2 * k - 1) wa,
               (select winner w, case when winner = p1 then n1 else n2 end n, case when winner = p1 then seed1 else seed2 end sd
                  from yippo_bracket_matches where week = p_week and round = r and slot = 2 * k) wb
          where wa.w is not null and wb.w is not null;
        end if;
      end loop;
    end if;
  end loop;
end $$;

-- Eenmalig: de kwalificatie duurt nu t/m donderdag. Een 'geen bracket'-regel die onder het oude schema (t/m woensdag)
-- al voor de huidige week is gemaakt, wordt verwijderd zodat de bracket alsnog kan starten.
delete from yippo_bracket_meta m
 where m.week = date_trunc('week', yippo_today())::date
   and yippo_today() - m.week < 4
   and not exists (select 1 from yippo_bracket_matches x where x.week = m.week);

-- Stand van het toernooi (voor de app). p_week leeg = de huidige week.
create or replace function yippo_bracket(p_week date default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_uid  uuid := auth.uid();
  v_today date := yippo_today();
  v_cur  date := date_trunc('week', v_today)::date;
  v_week date := least(coalesce(p_week, v_cur), v_cur);
  v_d int; v_size int; v_fr int; v_cr int; v_phase text;
  v_end timestamptz; v_left int;
  v_qual jsonb; v_my_rank int; v_my_score int; v_total int;
  v_matches jsonb; v_my jsonb := null; mm record; pl record; v_in boolean;
begin
  if v_week < date '2026-11-23' then
    return jsonb_build_object('phase', 'legacy', 'week', v_week, 'start', date '2026-11-23');
  end if;
  perform yippo_bracket_ensure(v_week);
  v_d := v_today - v_week;
  select size into v_size from yippo_bracket_meta where week = v_week;
  v_fr := case v_size when 8 then 1 when 4 then 2 else 3 end;
  v_cr := case when v_d >= 4 and v_size > 0 then v_fr + (v_d - 4) end;
  v_phase := case when v_d <= 3 then 'qual'
                  when v_size is null or v_size = 0 then 'none'
                  when v_cr <= 3 then 'r' || v_cr
                  else 'done' end;
  -- einde van de huidige fase (middernacht Amsterdam)
  v_end := case when v_phase = 'qual' then ((v_week + 4)::timestamp at time zone 'Europe/Amsterdam')
                when v_phase in ('r1', 'r2', 'r3') then ((v_week + 5 + (v_cr - v_fr))::timestamp at time zone 'Europe/Amsterdam')
                when v_phase in ('done', 'none') then ((v_week + 7)::timestamp at time zone 'Europe/Amsterdam') end;
  v_left := greatest(0, extract(epoch from (v_end - yippo_now()))::int);

  -- kwalificatieranglijst (ma-wo): beste score van de speler
  with q as (
    select player_id, max(score) sc, max(updated_at) t, (array_agg(name order by updated_at desc))[1] nm
    from yippo_tour_scores where day between v_week and v_week + 3
    group by player_id having max(score) > 0
  ), r as (select q.*, row_number() over (order by sc desc, t) rk, count(*) over () n from q)
  select coalesce(jsonb_agg(jsonb_build_object('rank', rk, 'name', nm, 'score', sc, 'me', player_id = v_uid) order by rk) filter (where rk <= 20), '[]'::jsonb),
         max(rk) filter (where player_id = v_uid), max(sc) filter (where player_id = v_uid), coalesce(max(n), 0)
    into v_qual, v_my_rank, v_my_score, v_total from r;

  select coalesce(jsonb_agg(jsonb_build_object(
      'round', m.round, 'slot', m.slot, 'n1', m.n1, 'n2', m.n2, 'seed1', m.seed1, 'seed2', m.seed2,
      'win', case when m.winner is null then null when m.winner = m.p1 then 1 else 2 end,
      's1', case when m.winner is not null then (select score from yippo_bracket_plays x where x.week = m.week and x.round = m.round and x.player_id = m.p1) end,
      's2', case when m.winner is not null then (select score from yippo_bracket_plays x where x.week = m.week and x.round = m.round and x.player_id = m.p2) end,
      'pl1', exists (select 1 from yippo_bracket_plays x where x.week = m.week and x.round = m.round and x.player_id = m.p1),
      'pl2', exists (select 1 from yippo_bracket_plays x where x.week = m.week and x.round = m.round and x.player_id = m.p2),
      'me1', m.p1 = v_uid, 'me2', m.p2 = v_uid) order by m.round, m.slot), '[]'::jsonb)
    into v_matches from yippo_bracket_matches m where m.week = v_week;

  if v_uid is not null then
    select exists (select 1 from yippo_bracket_matches where week = v_week and (p1 = v_uid or p2 = v_uid)) into v_in;
    select * into mm from yippo_bracket_matches
      where week = v_week and round = v_cr and (p1 = v_uid or p2 = v_uid) limit 1;
    if v_phase in ('r1', 'r2', 'r3') and mm.week is not null then
      select * into pl from yippo_bracket_plays where week = v_week and round = v_cr and player_id = v_uid;
      v_my := jsonb_build_object('in_bracket', true, 'alive', true, 'round', v_cr, 'slot', mm.slot,
         'opponent', case when mm.p1 = v_uid then mm.n2 else mm.n1 end,
         'bye', mm.p2 is null,
         'played', pl.week is not null,
         'can_play', mm.p2 is not null and mm.winner is null and pl.week is null);
    else
      v_my := jsonb_build_object('in_bracket', coalesce(v_in, false), 'alive', false);
    end if;
  end if;

  return jsonb_build_object('phase', v_phase, 'week', v_week, 'today', v_today, 'day', v_d, 'size', coalesce(v_size, 0),
    'round', v_cr, 'left_s', v_left, 'qual', v_qual, 'qual_total', v_total, 'my_rank', v_my_rank, 'my_score', v_my_score,
    'matches', v_matches, 'my', v_my);
end $$;

-- Je wedstrijd van deze ronde starten: één poging. De app start daarna het spel van 60 seconden.
create or replace function yippo_bracket_start(p_week date)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid(); v_today date := yippo_today(); v_d int; v_size int; v_fr int; v_cr int; mm record;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if p_week is null or p_week < date '2026-11-23' or p_week > v_today then raise exception 'bad_day'; end if;
  perform yippo_bracket_ensure(p_week);
  v_d := v_today - p_week;
  select size into v_size from yippo_bracket_meta where week = p_week;
  if v_size is null or v_size = 0 or v_d < 4 then raise exception 'no_match'; end if;
  v_fr := case v_size when 8 then 1 when 4 then 2 else 3 end;
  v_cr := v_fr + (v_d - 4);
  if v_cr > 3 then raise exception 'no_match'; end if;
  select * into mm from yippo_bracket_matches
    where week = p_week and round = v_cr and (p1 = v_uid or p2 = v_uid) and p2 is not null and winner is null limit 1;
  if mm.week is null then raise exception 'no_match'; end if;
  if exists (select 1 from yippo_bracket_plays where week = p_week and round = v_cr and player_id = v_uid) then
    raise exception 'already_played';
  end if;
  insert into yippo_bracket_plays (week, round, player_id) values (p_week, v_cr, v_uid);
  return jsonb_build_object('ok', true, 'round', v_cr);
end $$;

-- Score van je wedstrijd opslaan (alleen kort na de start en maar één keer).
create or replace function yippo_bracket_submit(p_week date, p_score int)
returns void
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_d int; v_size int; v_fr int; v_cr int;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if p_score is null or p_score < 0 or p_score > 100000 then raise exception 'bad_score'; end if;
  v_d := yippo_today() - p_week;
  select size into v_size from yippo_bracket_meta where week = p_week;
  if v_size is null or v_size = 0 or v_d < 4 then raise exception 'no_match'; end if;
  v_fr := case v_size when 8 then 1 when 4 then 2 else 3 end;
  v_cr := v_fr + (v_d - 4);
  update yippo_bracket_plays set score = p_score
   where week = p_week and round = v_cr and player_id = v_uid and score is null
     and started_at > now() - interval '5 minutes';
end $$;

-- Uitslag van een afgelopen week voor de prijzenkast: 1 kampioen, 2 finalist, 3 halve finale, 4 meegedaan.
create or replace function yippo_bracket_result(p_week date)
returns table (r int, s int)
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_best int; v_r int;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if p_week is null or p_week < date '2026-11-23' or yippo_today() - p_week < 7 then return; end if;
  perform yippo_bracket_ensure(p_week);
  select max(score) into v_best from yippo_tour_scores where player_id = v_uid and day between p_week and p_week + 3;
  if coalesce(v_best, 0) <= 0 then return; end if;
  v_r := case
    when exists (select 1 from yippo_bracket_matches where week = p_week and round = 3 and winner = v_uid) then 1
    when exists (select 1 from yippo_bracket_matches where week = p_week and round = 3 and (p1 = v_uid or p2 = v_uid)) then 2
    when exists (select 1 from yippo_bracket_matches where week = p_week and round = 2 and (p1 = v_uid or p2 = v_uid)) then 3
    else 4 end;
  return query select v_r, v_best;
end $$;

-- Voor later (pushmeldingen): wie moet er deze ronde spelen? Alleen voor de server (service_role), bv. elke dag om 00:05.
create or replace function yippo_bracket_players_to_notify()
returns table (player_id uuid, week date, round int, opponent text)
language plpgsql security definer set search_path = public as $$
declare v_week date := date_trunc('week', yippo_today())::date;
        v_d int := yippo_today() - date_trunc('week', yippo_today())::date; v_size int; v_cr int; v_fr int;
begin
  perform yippo_bracket_ensure(v_week);
  select size into v_size from yippo_bracket_meta where yippo_bracket_meta.week = v_week;
  if v_size is null or v_size = 0 or v_d < 4 then return; end if;
  v_fr := case v_size when 8 then 1 when 4 then 2 else 3 end;
  v_cr := v_fr + (v_d - 4);
  if v_cr > 3 then return; end if;
  return query
    select x.pid, v_week, v_cr, x.opp from (
      select m.p1 pid, m.n2 opp from yippo_bracket_matches m where m.week = v_week and m.round = v_cr and m.p2 is not null and m.winner is null
      union all
      select m.p2, m.n1 from yippo_bracket_matches m where m.week = v_week and m.round = v_cr and m.p2 is not null and m.winner is null) x
    where not exists (select 1 from yippo_bracket_plays p where p.week = v_week and p.round = v_cr and p.player_id = x.pid);
end $$;

revoke all on function yippo_now(), yippo_today(), yippo_bracket_ensure(date), yippo_bracket(date), yippo_bracket_start(date),
  yippo_bracket_submit(date, int), yippo_bracket_result(date), yippo_bracket_players_to_notify() from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on function yippo_bracket_start(date), yippo_bracket_submit(date, int), yippo_bracket_result(date) from anon;
    grant execute on function yippo_bracket(date) to anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function yippo_bracket(date), yippo_bracket_start(date), yippo_bracket_submit(date, int), yippo_bracket_result(date) to authenticated;
  end if;
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant execute on function yippo_bracket_players_to_notify() to service_role;
  end if;
end $$;

-- ========== TESTEN (optioneel, in de SQL-editor) ==========
-- Klok een dag vooruit zetten, bijvoorbeeld om de kwartfinale te zien:   update yippo_test_clock set shift = interval '3 days' where id = 1;
-- Terug naar normaal (altijd doen na het testen!):                        update yippo_test_clock set shift = interval '0 seconds' where id = 1;
