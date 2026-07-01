-- ============================================================
--  ATHAR — Persist all signup details on Supabase
--  Adds "special needs" to profiles and a PRIVATE id_documents table
--  (only the user themselves and admins can read an ID photo).
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

-- Special needs note on the profile
alter table public.profiles add column if not exists special_needs text;

-- Private ID photos — kept OUT of the public-readable profiles table
create table if not exists public.id_documents (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  id_photo   text,
  updated_at timestamptz not null default now()
);

alter table public.id_documents enable row level security;

drop policy if exists "id doc self insert" on public.id_documents;
create policy "id doc self insert" on public.id_documents
  for insert with check ( auth.uid() = user_id );

drop policy if exists "id doc self update" on public.id_documents;
create policy "id doc self update" on public.id_documents
  for update using ( auth.uid() = user_id );

drop policy if exists "id doc read self or admin" on public.id_documents;
create policy "id doc read self or admin" on public.id_documents
  for select using ( auth.uid() = user_id or public.is_admin() );
