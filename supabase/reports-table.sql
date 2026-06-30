-- ============================================================
--  ATHAR — Reports table (so user reports reach the admin)
--
--  Any signed-in user can file a report; only admins can read/resolve them.
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

create table if not exists public.reports (
  id           uuid primary key default gen_random_uuid(),
  target_type  text,                 -- campaign | post | user | comment
  target_id    text,
  reason       text,
  note         text,
  reporter_id  uuid references public.profiles(id) on delete set null,
  status       text not null default 'open',   -- open | resolved | dismissed
  created_at   timestamptz not null default now()
);

alter table public.reports enable row level security;

drop policy if exists "reports insert" on public.reports;
create policy "reports insert" on public.reports
  for insert with check ( auth.uid() is not null );   -- any signed-in user can report

drop policy if exists "reports read admin" on public.reports;
create policy "reports read admin" on public.reports
  for select using ( public.is_admin() );             -- only admins read reports

drop policy if exists "reports update admin" on public.reports;
create policy "reports update admin" on public.reports
  for update using ( public.is_admin() );             -- only admins resolve/dismiss

-- Enable realtime (so new reports reach the admin live). Safe to re-run.
do $$
begin
  begin
    execute 'alter publication supabase_realtime add table public.reports';
  exception when duplicate_object then null; when undefined_table then null;
  end;
end $$;
