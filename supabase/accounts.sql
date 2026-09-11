-- ============================================================================
-- BioVerseAR — Accounts migration, Phase 1 (student login + real names)
-- Run in Supabase SQL Editor. Safe to re-run.
--
-- Adds two columns to the existing profiles table:
--   full_name : the student's REAL name — PRIVATE (teacher-only, later phase).
--   role      : 'student' or 'teacher'.
--
-- Privacy: full_name stays private automatically —
--   * profiles_select_own already limits row reads to the owner (peers can't read it),
--   * the leaderboard functions (get_leaderboard / get_scores) never select it,
--   so real names never appear on any leaderboard. A teacher-roster function that
--   exposes real names to a student's OWN teacher is added in Phase 2.
-- ============================================================================

alter table public.profiles add column if not exists full_name text;

alter table public.profiles add column if not exists role text not null default 'student'
  check (role in ('student', 'teacher'));
