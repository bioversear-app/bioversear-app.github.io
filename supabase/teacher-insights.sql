-- ============================================================================
-- BioVerseAR — Teacher insights + class management.
-- Run ONCE in the Supabase SQL Editor, after schema.sql / teacher.sql / avatars.sql.
-- Safe to re-run (idempotent).
--
-- Adds two SECURITY DEFINER functions, both restricted to the class's OWNING
-- teacher (so one teacher can never read another teacher's students):
--   1. get_class_scores(code) — per-(student, topic) scores + pass flag, WITH the
--      student's real name. Powers the per-topic class insights and the per-student
--      drill-down on the teacher page.
--   2. rename_class(id, name) — rename one of your own classes.
-- ============================================================================

-- 1) per-(student, topic) scores for the owning teacher's class -------------
create or replace function public.get_class_scores(p_code text)
returns table (student_id uuid, full_name text, alias text, avatar text,
               topic_id text, score bigint, passed boolean)
language sql security definer set search_path = public as $$
  select p.id, p.full_name, p.alias, p.avatar, a.topic_id,
         sum(a.score)::bigint as score,
         bool_or(a.max > 0 and a.score >= a.max * 0.6) as passed
  from public.profiles p
  join public.attempts a on a.user_id = p.id
  where p.role = 'student'
    and public.bv_norm(p.class_code) = public.bv_norm(p_code)
    and exists (select 1 from public.classes c
                where c.teacher_id = auth.uid()
                  and public.bv_norm(c.code) = public.bv_norm(p_code))
  group by p.id, p.full_name, p.alias, p.avatar, a.topic_id;
$$;
grant execute on function public.get_class_scores(text) to authenticated;

-- 2) rename one of your own classes -----------------------------------------
create or replace function public.rename_class(p_id uuid, p_name text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  if p_name is null or length(trim(p_name)) = 0 then return false; end if;
  update public.classes set name = trim(p_name)
    where id = p_id and teacher_id = auth.uid();
  return found;
end; $$;
grant execute on function public.rename_class(uuid, text) to authenticated;
