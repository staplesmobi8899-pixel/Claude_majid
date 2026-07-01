-- ============================================================
--  ATHAR — add rejection_reason to profiles
--  Stores why an account was rejected, so the user sees the reason
--  and can review & resubmit.
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================
alter table public.profiles add column if not exists rejection_reason text;
