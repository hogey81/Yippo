-- Yippo: maximale dagscore van 50.000 naar 100.000 (speciale dieren leveren nu bonuspunten op).
-- Plak dit in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.

-- 1. De grens in de tabel
alter table yippo_scores drop constraint if exists yippo_scores_score_check;
alter table yippo_scores add constraint yippo_scores_score_check check (score between 0 and 100000);

-- 2. De grens in de functie die scores opslaat
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
  if p_score is null or p_score < 0 or p_score > 100000 then raise exception 'bad_score'; end if;

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
