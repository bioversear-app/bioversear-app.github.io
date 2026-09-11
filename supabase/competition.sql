-- ============================================================================
-- BioVerseAR — Competition mode (Model A): optional class code + speed tie-break.
-- Run this ONCE in the Supabase SQL Editor, AFTER schema.sql / teacher.sql /
-- avatars.sql. Safe to re-run (idempotent).
--
-- What it does:
--   1. attempts.time_ms  — total "thinking time" (ms) of the best attempt, so the
--      leaderboard can break ties by speed (faster wins).
--   2. keep-best trigger  — on equal score, keep the FASTER attempt.
--   3. get_leaderboard / get_scores — now return time_ms AND only include
--      COMPETITORS (students who have a class code). Explorers (no class code)
--      simply don't appear on the boards; they can join a competition any time
--      by entering a class code in their profile.
--
-- Ranking (applied in the app): score DESC, then time_ms ASC, then alias — a
-- strict order, so two students can never share a rank.
-- ============================================================================

-- 1) speed column ------------------------------------------------------------
alter table public.attempts add column if not exists time_ms integer;

-- 2) keep BEST score, and the FASTER of equal scores -------------------------
create or replace function public.attempts_keep_best()
returns trigger language plpgsql as $$
begin
  if tg_op = 'UPDATE' then
    if new.score < old.score then
      return old;                                   -- worse score: keep old
    end if;
    if new.score = old.score
       and coalesce(new.time_ms, 2147483647) >= coalesce(old.time_ms, 2147483647) then
      return old;                                   -- same score, not faster: keep old
    end if;
  end if;
  new.updated_at := now();
  return new;                                       -- higher score, or equal+faster
end; $$;
-- (trigger itself is already created by schema.sql; replacing the function is enough)

-- 3) leaderboard: competitors only, now carries time_ms ----------------------
drop function if exists public.get_leaderboard();
create function public.get_leaderboard()
returns table (alias text, class_code text, avatar text, score bigint, badges bigint, time_ms bigint)
language sql security definer set search_path = public as $$
  select p.alias, p.class_code, p.avatar,
         coalesce(sum(a.score), 0)::bigint as score,
         count(distinct case when a.max > 0 and a.score >= a.max * 0.6 then a.topic_id end)::bigint as badges,
         coalesce(sum(a.time_ms), 0)::bigint as time_ms
  from public.profiles p
  left join public.attempts a on a.user_id = p.id
  where p.role = 'student'
    and p.class_code is not null and length(trim(p.class_code)) > 0   -- competitors only
  group by p.id, p.alias, p.class_code, p.avatar
  order by score desc, time_ms asc, p.alias asc;
$$;
grant execute on function public.get_leaderboard() to anon, authenticated;

-- 4) per-(student, topic) scores: competitors only, now carries time_ms ------
drop function if exists public.get_scores();
create function public.get_scores()
returns table (alias text, class_code text, avatar text, topic_id text, score bigint, passed boolean, time_ms bigint)
language sql security definer set search_path = public as $$
  select p.alias, p.class_code, p.avatar, a.topic_id,
         sum(a.score)::bigint as score,
         bool_or(a.max > 0 and a.score >= a.max * 0.6) as passed,
         coalesce(sum(a.time_ms), 0)::bigint as time_ms
  from public.profiles p
  join public.attempts a on a.user_id = p.id
  where p.role = 'student'
    and p.class_code is not null and length(trim(p.class_code)) > 0   -- competitors only
  group by p.id, p.alias, p.class_code, p.avatar, a.topic_id;
$$;
grant execute on function public.get_scores() to anon, authenticated;

-- Note: existing attempts made before this migration have time_ms = NULL (counted
-- as 0). Only attempts taken after the migration record real times, so start the
-- competition fresh (or have students retake) for the speed tie-break to be fair.
