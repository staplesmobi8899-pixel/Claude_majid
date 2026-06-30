-- ============================================================
--  ATHAR — Make YOUR personal account the admin (no fake account)
--
--  The app grants the full admin dashboard to any account whose
--  profile role is 'admin' (level 10) — and RLS (is_admin) lets that
--  account approve/manage everyone. So you don't need admin@athar.sy:
--  just promote your own real account.
--
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

-- (Run this once, if you haven't already, so admins are recognized by RLS.)
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'super_admin')
  );
$$;

-- Promote your personal account to admin.
update public.profiles
set role = 'admin', status = 'approved'
where email = 'majedikhwan24@gmail.com';

-- Verify — should return one row with role = admin.
select email, name, role, status
from public.profiles
where email = 'majedikhwan24@gmail.com';
