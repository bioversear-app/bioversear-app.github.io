-- ============================================================================
-- BioVerseAR — validate a class code + return its name (for students joining).
-- Run ONCE in the Supabase SQL Editor. Safe to re-run.
--
-- Lets a signed-in student check that a class code is real and get the class
-- NAME (so the app shows "Grade 7 - Rizal", not the raw code) — and reject
-- codes that don't exist. Returns only the class name, never students.
-- ============================================================================
create or replace function public.class_by_code(p_code text)
returns table (name text)
language sql security definer set search_path = public as $$
  select c.name from public.classes c
  where public.bv_norm(c.code) = public.bv_norm(p_code)
  limit 1;
$$;
grant execute on function public.class_by_code(text) to authenticated;
