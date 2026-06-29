-- ============================================================
--  ATHAR — FIX: admin can't approve/manage users (RLS)
--
--  Symptom: admin approves a user → shows "Approved" locally, but after
--  reopening the app it reverts to "Under review", and the user never
--  becomes approved on their own device.
--
--  Cause: the profiles UPDATE policy allows admins via public.is_admin(),
--  which checks the *database* role of the signed-in admin. The admin
--  account's profile role was not 'admin' (default new accounts are
--  'volunteer'), so RLS silently blocked the write (0 rows changed) and
--  the next sync pulled the old 'pending' status back.
--
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste all → Run.
-- ============================================================

-- 1) Accept both 'admin' and 'super_admin' as database admins.
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'super_admin')
  );
$$;

-- 2) Promote the ATHAR admin account to a real DB admin.
--    (Make sure admin@athar.sy already exists as an Auth user.)
update public.profiles
set role = 'admin', status = 'approved'
where email = 'admin@athar.sy';

-- 3) Verify — this should return one row with role = admin.
--    select email, role, status from public.profiles where email = 'admin@athar.sy';
