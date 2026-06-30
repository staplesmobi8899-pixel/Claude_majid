-- ============================================================
--  ATHAR — add date-of-birth column to profiles
--  So DOB entered at signup (and edited by admin) persists & syncs.
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================
alter table public.profiles add column if not exists dob date;
