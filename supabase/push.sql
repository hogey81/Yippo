-- Yippo: pushmeldingen "iemand in je league heeft het dagrecord verbeterd" (voorbereiding voor de Android-app)
-- Plak dit bestand in Supabase: SQL Editor -> New query -> Run. Veilig om opnieuw te draaien.
-- Pas draaien als yippo.sql al is gedraaid. Er wordt nog niets verstuurd zolang de serverfunctie
-- (supabase/functions/push-record) niet is uitgerold: zie supabase/push.md.

-- ========== Tabellen ==========
-- Aangemelde telefoons. Alleen voor volwassen accounts die meldingen zelf aanzetten.
create table if not exists yippo_devices (
  token         text primary key,
  player_id     uuid not null,
  lang          text not null default 'nl' check (lang in ('nl','en','es')),
  last_push_day date,
  created_at    timestamptz not null default now()
);
create index if not exists yippo_devices_player on yippo_devices (player_id);

-- Wachtrij: elke keer dat iemand het dagrecord van een league verbetert komt hier een regel in.
create table if not exists yippo_push_queue (
  id         bigserial primary key,
  day        date not null,
  player_id  uuid not null,
  name       text not null,
  score      int  not null,
  league_code text not null,
  league_name text not null,
  created_at timestamptz not null default now(),
  sent_at    timestamptz
);
create index if not exists yippo_push_queue_open on yippo_push_queue (created_at) where sent_at is null;

alter table yippo_devices    enable row level security;
alter table yippo_push_queue enable row level security;
revoke all on yippo_devices, yippo_push_queue from public;
revoke all on yippo_devices, yippo_push_queue from anon, authenticated;

-- ========== Telefoon aan- en afmelden ==========
-- Alleen volwassen accounts (de app slaat 'adult' of 'child' op in de voortgang, nooit het geboortejaar).
create or replace function yippo_register_device(p_token text, p_lang text default 'nl')
returns void
language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid();
  v_age text;
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  if p_token is null or char_length(p_token) not between 20 and 4096 then raise exception 'bad_token'; end if;
  select data ->> 'age' into v_age from yippo_profiles where user_id = v_uid;
  if v_age is distinct from 'adult' then raise exception 'adults_only'; end if;
  insert into yippo_devices as d (token, player_id, lang)
  values (p_token, v_uid, case when p_lang in ('nl','en','es') then p_lang else 'nl' end)
  on conflict (token) do update set player_id = v_uid, lang = excluded.lang;
end $$;

create or replace function yippo_unregister_device(p_token text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not_signed_in'; end if;
  delete from yippo_devices where token = p_token and player_id = auth.uid();
end $$;

grant execute on function yippo_register_device(text, text), yippo_unregister_device(text) to authenticated;

-- ========== Record opmerken ==========
-- Zodra een score hoger is dan alle andere scores van die dag in een league waar de speler in zit,
-- komt er een regel in de wachtrij. De eerste score van een dag in een league telt niet: er is dan nog niets verbeterd.
create or replace function yippo_scores_record_trg()
returns trigger
language plpgsql security definer set search_path = public as $$
declare
  l record;
  v_prev int;
begin
  if tg_op = 'UPDATE' and new.score <= old.score then return new; end if;
  for l in
    select m.code, g.name from yippo_members m join yippo_leagues g on g.code = m.code where m.player_id = new.player_id
  loop
    select max(s.score) into v_prev
      from yippo_scores s
      join yippo_members m2 on m2.player_id = s.player_id and m2.code = l.code
      where s.day = new.day and s.player_id <> new.player_id;
    if v_prev is not null and new.score > v_prev then
      insert into yippo_push_queue (day, player_id, name, score, league_code, league_name)
      values (new.day, new.player_id, new.name, new.score, l.code, l.name);
    end if;
  end loop;
  return new;
end $$;

drop trigger if exists yippo_scores_record on yippo_scores;
create trigger yippo_scores_record after insert or update of score on yippo_scores
  for each row execute function yippo_scores_record_trg();

-- ========== Account verwijderen: ook de telefoons en wachtrij opruimen ==========
create or replace function yippo_delete_account()
returns void
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'not_signed_in'; end if;
  delete from yippo_devices    where player_id = v_uid;
  delete from yippo_push_queue where player_id = v_uid;
  delete from yippo_scores   where player_id = v_uid;
  delete from yippo_members  where player_id = v_uid;
  delete from yippo_leagues l where not exists (select 1 from yippo_members m where m.code = l.code);
  delete from yippo_profiles where user_id = v_uid;
  delete from auth.users     where id = v_uid;
end $$;
