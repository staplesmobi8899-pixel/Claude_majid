-- ============================================================
--  ATHAR — Ensure ALL columns & tables exist (idempotent)
--  Run this ONCE to guarantee every migration is applied. Safe to re-run.
--  If admin edits weren't saving, a missing column was the likely cause —
--  this fixes it.
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

-- ---- profiles: all added columns ----
alter table public.profiles add column if not exists dob              date;
alter table public.profiles add column if not exists special_needs    text;
alter table public.profiles add column if not exists rejection_reason text;

-- ---- reports ----
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  target_type text, target_id text, reason text, note text,
  reporter_id uuid references public.profiles(id) on delete set null,
  status text not null default 'open',
  created_at timestamptz not null default now()
);
alter table public.reports enable row level security;
drop policy if exists "reports insert" on public.reports;
create policy "reports insert" on public.reports for insert with check ( auth.uid() is not null );
drop policy if exists "reports read admin" on public.reports;
create policy "reports read admin" on public.reports for select using ( public.is_admin() );
drop policy if exists "reports update admin" on public.reports;
create policy "reports update admin" on public.reports for update using ( public.is_admin() );

-- ---- id_documents (private) ----
create table if not exists public.id_documents (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  id_photo text, updated_at timestamptz not null default now()
);
alter table public.id_documents enable row level security;
drop policy if exists "id doc self insert" on public.id_documents;
create policy "id doc self insert" on public.id_documents for insert with check ( auth.uid() = user_id );
drop policy if exists "id doc self update" on public.id_documents;
create policy "id doc self update" on public.id_documents for update using ( auth.uid() = user_id );
drop policy if exists "id doc read self or admin" on public.id_documents;
create policy "id doc read self or admin" on public.id_documents for select using ( auth.uid() = user_id or public.is_admin() );
drop policy if exists "id doc write admin" on public.id_documents;
create policy "id doc write admin" on public.id_documents for all using ( public.is_admin() ) with check ( public.is_admin() );

-- ---- site_content ----
create table if not exists public.site_content (
  id text primary key, data jsonb, updated_at timestamptz not null default now()
);
alter table public.site_content enable row level security;
drop policy if exists "content read" on public.site_content;
create policy "content read" on public.site_content for select using ( true );
drop policy if exists "content write admin" on public.site_content;
create policy "content write admin" on public.site_content for all using ( public.is_admin() ) with check ( public.is_admin() );

-- ---- realtime for the newer tables (safe if already added) ----
do $$
declare t text;
begin
  foreach t in array array['reports','site_content','id_documents']
  loop
    begin execute format('alter publication supabase_realtime add table public.%I', t);
    exception when duplicate_object then null; when undefined_table then null; end;
  end loop;
end $$;

-- ---- is_admin() + profiles update policy (lets appointed admins edit users) ----
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'super_admin')
  );
$$;
drop policy if exists "profiles update self or admin" on public.profiles;
create policy "profiles update self or admin" on public.profiles
  for update using ( auth.uid() = id or public.is_admin() );
