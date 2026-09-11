-- ============================================================================
-- BioVerseAR — Supabase schema
-- Paste this whole file into your Supabase project's SQL Editor and click "Run".
-- Safe to re-run (idempotent).
--
-- Identity model: anonymous auth. Each device gets a hidden auth user; the
-- student types an alias + class code (no real names, no passwords), stored in
-- `profiles`. Quiz results go to `attempts` (best kept per topic+difficulty).
-- The leaderboard is a SECURITY DEFINER function that returns only aggregates
-- (alias, class code, total score, badge count) — never per-question data.
-- ============================================================================

-- 1) PROFILES ---------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  alias       text not null check (char_length(alias) between 1 and 40),
  class_code  text not null check (char_length(class_code) between 1 and 40),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
drop policy if exists profiles_insert_own on public.profiles;
drop policy if exists profiles_update_own on public.profiles;

create policy profiles_select_own on public.profiles
  for select using (auth.uid() = id);
create policy profiles_insert_own on public.profiles
  for insert with check (auth.uid() = id);
create policy profiles_update_own on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- 2) ATTEMPTS (best attempt per topic + difficulty) -------------------------
create table if not exists public.attempts (
  user_id     uuid not null references auth.users(id) on delete cascade,
  topic_id    text not null,
  difficulty  text not null check (difficulty in ('easy','medium','hard')),
  score       int  not null,
  max         int  not null,
  correct     int  not null,
  total       int  not null,
  answers     jsonb,
  flagged     jsonb,
  updated_at  timestamptz not null default now(),
  primary key (user_id, topic_id, difficulty)
);

alter table public.attempts enable row level security;

drop policy if exists attempts_select_own on public.attempts;
drop policy if exists attempts_insert_own on public.attempts;
drop policy if exists attempts_update_own on public.attempts;

create policy attempts_select_own on public.attempts
  for select using (auth.uid() = user_id);
create policy attempts_insert_own on public.attempts
  for insert with check (auth.uid() = user_id);
create policy attempts_update_own on public.attempts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Keep the BEST score: on an upsert conflict, never overwrite a higher score
-- (protects the record if a student clears local storage and replays worse).
create or replace function public.attempts_keep_best()
returns trigger language plpgsql as $$
begin
  if tg_op = 'UPDATE' and new.score < old.score then
    return old;              -- keep the better existing row
  end if;
  new.updated_at := now();
  return new;
end; $$;

drop trigger if exists attempts_keep_best_trg on public.attempts;
create trigger attempts_keep_best_trg
  before update on public.attempts
  for each row execute function public.attempts_keep_best();

-- Table privileges for the API roles. RLS (above) still restricts WHICH rows
-- each user can touch — these grants just let the roles reach the tables at all.
grant usage on schema public to anon, authenticated;
grant select, insert, update on public.profiles to anon, authenticated;
grant select, insert, update on public.attempts to anon, authenticated;

-- 3) LEADERBOARD (aggregate only; safe to expose) ---------------------------
create or replace function public.get_leaderboard()
returns table (alias text, class_code text, score bigint, badges bigint)
language sql
security definer
set search_path = public
as $$
  select p.alias,
         p.class_code,
         coalesce(sum(a.score), 0)::bigint as score,
         count(distinct case when a.max > 0 and a.score >= a.max * 0.6
                             then a.topic_id end)::bigint as badges
  from public.profiles p
  left join public.attempts a on a.user_id = p.id
  group by p.id, p.alias, p.class_code
  order by score desc, badges desc;
$$;

grant execute on function public.get_leaderboard() to anon, authenticated;

-- 4) PER-TOPIC SCORES (powers the topic + overall leaderboards) --------------
-- One row per (student, topic): their total score in that topic and whether
-- they've passed it. The client aggregates this into overall or per-topic boards.
create or replace function public.get_scores()
returns table (alias text, class_code text, topic_id text, score bigint, passed boolean)
language sql
security definer
set search_path = public
as $$
  select p.alias, p.class_code, a.topic_id,
         sum(a.score)::bigint as score,
         bool_or(a.max > 0 and a.score >= a.max * 0.6) as passed
  from public.profiles p
  join public.attempts a on a.user_id = p.id
  group by p.id, p.alias, p.class_code, a.topic_id;
$$;

grant execute on function public.get_scores() to anon, authenticated;
