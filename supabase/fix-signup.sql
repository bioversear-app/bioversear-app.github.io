-- ============================================================================
-- BioVerseAR — Sign-up hardening patch
-- Run in Supabase SQL Editor. Idempotent — safe to run once, or again.
--
-- Symptom this fixes: "Account created, but there was a problem — contact your
-- teacher." The auth account is made, but the follow-up INSERT into `profiles`
-- is rejected, leaving a half-made account.
--
-- Two DB-side causes are removed here:
--   1) `class_code` still NOT NULL  → an Explorer (no class code) sends NULL and
--      the insert fails. The optional-class-code design needs this column nullable.
--      (This was meant to be applied in teacher.sql; re-asserted here in case a
--      live database was set up before that, or ran the migrations out of order.)
--   2) Missing/renamed RLS policies → the owner can't insert their own row.
--
-- NOTE: The most common NON-database cause is unaffected by this file:
--   "Confirm email" must be OFF in Supabase → Authentication → Providers → Email.
--   With it ON, sign-up returns no session and RLS blocks the insert. The client
--   now signs the user in to recover, but keeping the setting OFF is still required.
-- ============================================================================

-- 1) Class code must be OPTIONAL (Explorers have none).
alter table public.profiles alter column class_code drop not null;

-- 2) Owner-only row policies (idempotent).
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

-- 3) Make sure the API roles can reach the table at all (RLS still limits rows).
grant usage on schema public to anon, authenticated;
grant select, insert, update on public.profiles to anon, authenticated;

-- 4) Optional cleanup: remove any ORPHANED auth users that have no profile row
--    (left behind by earlier half-made sign-ups, which then block that username).
--    Review before running — this permanently deletes those auth users.
--    Uncomment to use:
-- delete from auth.users u
--   where u.email like '%@students.bioversear.app'
--     and not exists (select 1 from public.profiles p where p.id = u.id);
