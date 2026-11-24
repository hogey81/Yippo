-- Yippo: vragenlijst voor testers (https://www.yippogame.com/feedback)
-- Plak dit hele bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- De antwoorden zijn anoniem (geen account, geen e-mail). Alleen jij ziet de samenvatting, op de beheerpagina.

create table if not exists yippo_feedback (
  id         bigserial primary key,
  created_at timestamptz not null default now(),
  lang       text,
  answers    jsonb not null
);
alter table yippo_feedback enable row level security;
revoke all on yippo_feedback from public, anon, authenticated;

-- Antwoorden opslaan (voor iedereen met de link). Alleen bekende antwoorden worden bewaard.
create or replace function yippo_feedback_submit(p_answers jsonb)
returns void
language plpgsql security definer set search_path = public as $$
declare
  v jsonb;
  allowed_tried   text[] := array['levels','daily','race','tournament','zoo','leagues','share'];
  allowed_liked   text[] := array['animals','specials','worlds','daily','race','tournament','looks','noads'];
  allowed_issues  text[] := array['none','confusing','bug','hard','easy','slow','sound','other'];
  v_rating int;
begin
  if p_answers is null or jsonb_typeof(p_answers) <> 'object' or octet_length(p_answers::text) > 6000 then raise exception 'bad_data'; end if;
  if (select count(*) from yippo_feedback where created_at > now() - interval '1 minute') > 40 then raise exception 'too_many'; end if;
  v_rating := case when (p_answers ->> 'rating') ~ '^[0-9]{1,2}$' and (p_answers ->> 'rating')::int between 1 and 10 then (p_answers ->> 'rating')::int end;
  v := jsonb_build_object(
    'freq',      case when p_answers ->> 'freq' in ('daily','weekly','few','once') then p_answers ->> 'freq' end,
    'tried',     coalesce((select jsonb_agg(distinct x) from jsonb_array_elements_text(case when jsonb_typeof(p_answers -> 'tried') = 'array' then p_answers -> 'tried' else '[]'::jsonb end) x where x = any (allowed_tried)), '[]'::jsonb),
    'liked',     coalesce((select jsonb_agg(distinct x) from jsonb_array_elements_text(case when jsonb_typeof(p_answers -> 'liked') = 'array' then p_answers -> 'liked' else '[]'::jsonb end) x where x = any (allowed_liked)), '[]'::jsonb),
    'issues',    coalesce((select jsonb_agg(distinct x) from jsonb_array_elements_text(case when jsonb_typeof(p_answers -> 'issues') = 'array' then p_answers -> 'issues' else '[]'::jsonb end) x where x = any (allowed_issues)), '[]'::jsonb),
    'rating',    v_rating,
    'recommend', case when p_answers ->> 'recommend' in ('yes','maybe','no') then p_answers ->> 'recommend' end,
    'device',    left(btrim(coalesce(p_answers ->> 'device', '')), 120),
    'remarks',   left(btrim(coalesce(p_answers ->> 'remarks', '')), 1500));
  insert into yippo_feedback (lang, answers) values (case when p_answers ->> 'lang' in ('nl','en','es') then p_answers ->> 'lang' end, v);
end $$;

-- Samenvatting voor de beheerpagina (alleen admins, zoals yippo_admin_stats).
create or replace function yippo_admin_feedback()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
begin
  if auth.uid() is null or v_email = '' or not exists (select 1 from yippo_admins where email = v_email) then
    raise exception 'not_admin';
  end if;
  return jsonb_build_object(
    'total',  (select count(*) from yippo_feedback),
    'rating_avg', (select round(avg((answers ->> 'rating')::numeric), 1) from yippo_feedback where answers ->> 'rating' is not null),
    'freq',      coalesce((select jsonb_object_agg(k, c) from (select answers ->> 'freq' k, count(*) c from yippo_feedback where answers ->> 'freq' is not null group by 1) s), '{}'::jsonb),
    'recommend', coalesce((select jsonb_object_agg(k, c) from (select answers ->> 'recommend' k, count(*) c from yippo_feedback where answers ->> 'recommend' is not null group by 1) s), '{}'::jsonb),
    'rating',    coalesce((select jsonb_object_agg(k, c) from (select answers ->> 'rating' k, count(*) c from yippo_feedback where answers ->> 'rating' is not null group by 1) s), '{}'::jsonb),
    'tried',     coalesce((select jsonb_object_agg(k, c) from (select x k, count(*) c from yippo_feedback, jsonb_array_elements_text(answers -> 'tried') x group by 1) s), '{}'::jsonb),
    'liked',     coalesce((select jsonb_object_agg(k, c) from (select x k, count(*) c from yippo_feedback, jsonb_array_elements_text(answers -> 'liked') x group by 1) s), '{}'::jsonb),
    'issues',    coalesce((select jsonb_object_agg(k, c) from (select x k, count(*) c from yippo_feedback, jsonb_array_elements_text(answers -> 'issues') x group by 1) s), '{}'::jsonb),
    'remarks',   coalesce((select jsonb_agg(jsonb_build_object('at', created_at, 'device', answers ->> 'device', 'text', answers ->> 'remarks') order by created_at desc)
                   from (select * from yippo_feedback where coalesce(answers ->> 'remarks', '') <> '' or coalesce(answers ->> 'device', '') <> '' order by created_at desc limit 100) r), '[]'::jsonb));
end $$;

revoke all on function yippo_feedback_submit(jsonb), yippo_admin_feedback() from public;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    grant execute on function yippo_feedback_submit(jsonb) to anon;
    revoke all on function yippo_admin_feedback() from anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function yippo_feedback_submit(jsonb), yippo_admin_feedback() to authenticated;
  end if;
end $$;
