-- ============================================================================
-- BioVerseAR — teacher activity + top score  (Phase 2)
--
-- READ-ONLY and ADDITIVE. This script:
--   * creates TWO new functions
--   * does NOT create, alter or drop any table
--   * does NOT add or remove any column
--   * does NOT modify a single row of student data
--   * does NOT touch get_class_scores / get_class_roster / any existing function
--
-- Why it's needed: public.attempts already stores updated_at (when a result was
-- saved) and score/max (for a real percentage), but no existing function hands
-- those to the teacher page. These two functions expose them — nothing more.
--
-- Safe to re-run. To undo completely, see the DROP lines at the bottom.
--
-- Authorization is unchanged: both functions are SECURITY DEFINER but filter on
-- c.teacher_id = auth.uid(), so a teacher can only ever see students in classes
-- they own — exactly the same rule the existing teacher functions use.
-- ============================================================================

-- 1) Recent results across every class this teacher owns ---------------------
--    Powers the "Recent Activity" feed with real timestamps.
create or replace function public.get_teacher_activity(p_limit int default 20)
returns table (
  student_id uuid,
  full_name  text,
  alias      text,
  avatar     text,
  class_code text,
  class_name text,
  topic_id   text,
  difficulty text,
  score      int,
  max        int,
  passed     boolean,
  updated_at timestamptz
)
language sql security definer set search_path = public as $$
  select p.id, p.full_name, p.alias, p.avatar,
         c.code, c.name,
         a.topic_id, a.difficulty,
         a.score, a.max,
         (a.max > 0 and a.score >= a.max * 0.6) as passed,
         a.updated_at
  from public.attempts a
  join public.profiles p on p.id = a.user_id
  join public.classes  c on public.bv_norm(c.code) = public.bv_norm(p.class_code)
  where p.role = 'student'
    and c.teacher_id = auth.uid()
  order by a.updated_at desc
  limit greatest(1, least(coalesce(p_limit, 20), 100));
$$;
grant execute on function public.get_teacher_activity(int) to authenticated;

-- 2) Highest single-quiz percentage across every class this teacher owns -----
--    Powers the "Top Score" tile. Returns at most one row.
create or replace function public.get_teacher_topscore()
returns table (
  best_pct   int,
  full_name  text,
  alias      text,
  topic_id   text,
  class_code text
)
language sql security definer set search_path = public as $$
  select round(a.score::numeric * 100 / a.max)::int as best_pct,
         p.full_name, p.alias, a.topic_id, c.code
  from public.attempts a
  join public.profiles p on p.id = a.user_id
  join public.classes  c on public.bv_norm(c.code) = public.bv_norm(p.class_code)
  where p.role = 'student'
    and c.teacher_id = auth.uid()
    and a.max > 0
  order by (a.score::numeric / a.max) desc, a.updated_at desc
  limit 1;
$$;
grant execute on function public.get_teacher_topscore() to authenticated;

-- ---------------------------------------------------------------------------
-- To undo Phase 2 entirely, run these two lines. Nothing else is affected:
--   drop function if exists public.get_teacher_activity(int);
--   drop function if exists public.get_teacher_topscore();
-- ---------------------------------------------------------------------------
