-- ============================================================================
-- BioVerseAR — Phase 2: teacher accounts, classes, roster, password reset.
-- Run in Supabase SQL Editor. Safe to re-run.
--
-- IMPORTANT: after running, set YOUR secret teacher sign-up code (last line):
--   update public.app_config set value = 'YOUR-SECRET-CODE' where key = 'teacher_code';
-- Only people who know this code can register as a teacher.
-- ============================================================================

create extension if not exists pgcrypto with schema extensions;

-- ---- classes -------------------------------------------------------------
create table if not exists public.classes (
  id          uuid primary key default gen_random_uuid(),
  code        text unique not null,
  name        text not null,
  teacher_id  uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);
alter table public.classes enable row level security;
drop policy if exists classes_select_own on public.classes;
create policy classes_select_own on public.classes for select using (auth.uid() = teacher_id);
grant select on public.classes to authenticated;

-- ---- secret config (teacher sign-up code) --------------------------------
-- RLS on + no policies + grants revoked => clients can't read it; only the
-- SECURITY DEFINER functions below (owned by postgres) can.
create table if not exists public.app_config (key text primary key, value text not null);
alter table public.app_config enable row level security;
revoke all on public.app_config from anon, authenticated;
insert into public.app_config(key, value) values ('teacher_code', 'CHANGE-ME')
  on conflict (key) do nothing;

-- ---- helper: normalize a class code for matching -------------------------
create or replace function public.bv_norm(t text)
returns text language sql immutable set search_path = public as $$
  select upper(regexp_replace(trim(coalesce(t, '')), '\s+', ' ', 'g'));
$$;

-- ---- promote caller to teacher if the secret code matches ----------------
create or replace function public.claim_teacher(code text)
returns boolean language plpgsql security definer set search_path = public as $$
declare ok boolean;
begin
  select (value = code) into ok from public.app_config where key = 'teacher_code';
  if coalesce(ok, false) then
    update public.profiles set role = 'teacher', updated_at = now() where id = auth.uid();
    return true;
  end if;
  return false;
end; $$;
grant execute on function public.claim_teacher(text) to authenticated;

-- ---- delete the caller's own account (clean up a failed teacher sign-up) --
create or replace function public.delete_self()
returns void language plpgsql security definer set search_path = public, auth as $$
begin
  delete from auth.users where id = auth.uid();  -- cascades to profiles
end; $$;
grant execute on function public.delete_self() to authenticated;

-- ---- teacher creates a class (auto-generated unique code) ----------------
create or replace function public.create_class(p_name text)
returns table (id uuid, code text, name text)
language plpgsql security definer set search_path = public as $$
#variable_conflict use_column
declare is_teacher boolean; new_code text; tries int := 0; nm text;
begin
  select (role = 'teacher') into is_teacher from public.profiles where id = auth.uid();
  if not coalesce(is_teacher, false) then raise exception 'Only teachers can create classes'; end if;
  nm := nullif(trim(p_name), '');
  if nm is null then raise exception 'Class name is required'; end if;
  loop
    tries := tries + 1;
    new_code := (
      select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', (floor(random() * 32) + 1)::int, 1), '')
      from generate_series(1, 5)
    );
    begin
      return query
        insert into public.classes(code, name, teacher_id)
        values (new_code, nm, auth.uid())
        returning classes.id, classes.code, classes.name;
      return;
    exception when unique_violation then
      if tries > 12 then raise; end if;
    end;
  end loop;
end; $$;
grant execute on function public.create_class(text) to authenticated;

-- ---- teacher's classes + student counts ----------------------------------
create or replace function public.get_teacher_classes()
returns table (id uuid, code text, name text, student_count bigint)
language sql security definer set search_path = public as $$
  select c.id, c.code, c.name,
         (select count(*) from public.profiles p
           where p.role = 'student' and public.bv_norm(p.class_code) = public.bv_norm(c.code))::bigint
  from public.classes c
  where c.teacher_id = auth.uid()
  order by c.created_at;
$$;
grant execute on function public.get_teacher_classes() to authenticated;

-- ---- roster of one class (real names + scores) — owning teacher only ------
create or replace function public.get_class_roster(p_code text)
returns table (student_id uuid, alias text, full_name text, score bigint, badges bigint)
language sql security definer set search_path = public as $$
  select p.id as student_id, p.alias, p.full_name,
         coalesce(sum(a.score), 0)::bigint as score,
         count(distinct case when a.max > 0 and a.score >= a.max * 0.6 then a.topic_id end)::bigint as badges
  from public.profiles p
  left join public.attempts a on a.user_id = p.id
  where p.role = 'student'
    and public.bv_norm(p.class_code) = public.bv_norm(p_code)
    and exists (select 1 from public.classes c
                where c.teacher_id = auth.uid() and public.bv_norm(c.code) = public.bv_norm(p_code))
  group by p.id, p.alias, p.full_name
  order by score desc;
$$;
grant execute on function public.get_class_roster(text) to authenticated;

-- ---- teacher resets a student's password ---------------------------------
-- Allowed only if the caller owns a class the student belongs to.
create or replace function public.reset_student_password(p_student uuid, p_password text)
returns boolean language plpgsql security definer set search_path = public, extensions, auth as $$
declare owns boolean;
begin
  if length(coalesce(p_password, '')) < 6 then raise exception 'Password must be at least 6 characters'; end if;
  select exists (
    select 1 from public.profiles s
    join public.classes c on public.bv_norm(c.code) = public.bv_norm(s.class_code)
    where s.id = p_student and s.role = 'student' and c.teacher_id = auth.uid()
  ) into owns;
  if not owns then return false; end if;
  update auth.users
     set encrypted_password = crypt(p_password, gen_salt('bf')), updated_at = now()
   where id = p_student;
  return true;
end; $$;
grant execute on function public.reset_student_password(uuid, text) to authenticated;

-- ============================================================================
-- FINAL STEP — set your secret teacher code (change the value!):
--   update public.app_config set value = 'YOUR-SECRET-CODE' where key = 'teacher_code';
-- ============================================================================

-- ---- Phase 2 fix: teachers have no class code; keep teachers off leaderboards ----
alter table public.profiles alter column class_code drop not null;

create or replace function public.get_leaderboard()
returns table (alias text, class_code text, score bigint, badges bigint)
language sql security definer set search_path = public as $$
  select p.alias, p.class_code,
         coalesce(sum(a.score), 0)::bigint as score,
         count(distinct case when a.max > 0 and a.score >= a.max * 0.6 then a.topic_id end)::bigint as badges
  from public.profiles p
  left join public.attempts a on a.user_id = p.id
  where p.role = 'student'
  group by p.id, p.alias, p.class_code
  order by score desc, badges desc;
$$;
grant execute on function public.get_leaderboard() to anon, authenticated;

create or replace function public.get_scores()
returns table (alias text, class_code text, topic_id text, score bigint, passed boolean)
language sql security definer set search_path = public as $$
  select p.alias, p.class_code, a.topic_id,
         sum(a.score)::bigint as score,
         bool_or(a.max > 0 and a.score >= a.max * 0.6) as passed
  from public.profiles p
  join public.attempts a on a.user_id = p.id
  where p.role = 'student'
  group by p.id, p.alias, p.class_code, a.topic_id;
$$;
grant execute on function public.get_scores() to anon, authenticated;
