-- ============================================================
--  ATHAR — Owner protection & admin-role restrictions
--
--  Goal: your account is the OWNER (super_admin). Regular 'admin' accounts
--  have full operational power, but at the database level they CANNOT:
--    • grant or revoke the admin / super_admin role, and
--    • modify (edit / ban / demote) a super_admin (owner) account.
--  Only the owner can create admins.
--
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

-- 1) Make your personal account the owner (super_admin).
update public.profiles
set role = 'super_admin', status = 'approved'
where email = 'majedikhwan24@gmail.com';

-- 2) Server-side guard: enforce the rules on every profile update.
create or replace function public.protect_admin_roles()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare actor_role text;
begin
  select role into actor_role from public.profiles where id = auth.uid();
  actor_role := coalesce(actor_role, '');

  -- Only a super_admin may grant/raise a role to admin or super_admin.
  if new.role in ('admin','super_admin')
     and new.role is distinct from old.role
     and actor_role <> 'super_admin' then
    raise exception 'Only the owner can grant admin roles';
  end if;

  -- Nobody but a super_admin may modify a super_admin (owner) account.
  if old.role = 'super_admin' and actor_role <> 'super_admin' then
    raise exception 'Cannot modify the owner account';
  end if;

  return new;
end;
$$;

drop trigger if exists protect_admin_roles_trg on public.profiles;
create trigger protect_admin_roles_trg
  before update on public.profiles
  for each row execute function public.protect_admin_roles();

-- Verify:
-- select email, role from public.profiles where role in ('admin','super_admin');
