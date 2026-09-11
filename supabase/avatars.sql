-- ============================================================================
-- BioVerseAR — Explorer avatars. Run once in the Supabase SQL Editor.
-- Safe to re-run (idempotent).
--
-- The avatar is a short id (e.g. 'kid-goggles') that maps to an inline SVG
-- character in the app — no image is ever uploaded. This migration:
--   1. adds profiles.avatar (so a student's choice syncs across devices), and
--   2. returns the avatar from the leaderboard / scores / roster functions so it
--      can show next to each student.
-- ============================================================================

alter table public.profiles add column if not exists avatar text;

-- ---- overall leaderboard (now returns avatar) ----------------------------
drop function if exists public.get_leaderboard();
create function public.get_leaderboard()
returns table (alias text, class_code text, avatar text, score bigint, badges bigint)
language sql security definer set search_path = public as $$
  select p.alias, p.class_code, p.avatar,
         coalesce(sum(a.score), 0)::bigint as score,
         count(distinct case when a.max > 0 and a.score >= a.max * 0.6 then a.topic_id end)::bigint as badges
  from public.profiles p
  left join public.attempts a on a.user_id = p.id
  where p.role = 'student'
  group by p.id, p.alias, p.class_code, p.avatar
  order by score desc, badges desc;
$$;
grant execute on function public.get_leaderboard() to anon, authenticated;

-- ---- per-(student, topic) scores (now returns avatar) --------------------
drop function if exists public.get_scores();
create function public.get_scores()
returns table (alias text, class_code text, avatar text, topic_id text, score bigint, passed boolean)
language sql security definer set search_path = public as $$
  select p.alias, p.class_code, p.avatar, a.topic_id,
         sum(a.score)::bigint as score,
         bool_or(a.max > 0 and a.score >= a.max * 0.6) as passed
  from public.profiles p
  join public.attempts a on a.user_id = p.id
  where p.role = 'student'
  group by p.id, p.alias, p.class_code, p.avatar, a.topic_id;
$$;
grant execute on function public.get_scores() to anon, authenticated;

-- ---- class roster (real names, now returns avatar) — owning teacher only --
drop function if exists public.get_class_roster(text);
create function public.get_class_roster(p_code text)
returns table (student_id uuid, alias text, full_name text, avatar text, score bigint, badges bigint)
language sql security definer set search_path = public as $$
  select p.id as student_id, p.alias, p.full_name, p.avatar,
         coalesce(sum(a.score), 0)::bigint as score,
         count(distinct case when a.max > 0 and a.score >= a.max * 0.6 then a.topic_id end)::bigint as badges
  from public.profiles p
  left join public.attempts a on a.user_id = p.id
  where p.role = 'student'
    and public.bv_norm(p.class_code) = public.bv_norm(p_code)
    and exists (select 1 from public.classes c
                where c.teacher_id = auth.uid() and public.bv_norm(c.code) = public.bv_norm(p_code))
  group by p.id, p.alias, p.full_name, p.avatar
  order by score desc;
$$;
grant execute on function public.get_class_roster(text) to authenticated;
