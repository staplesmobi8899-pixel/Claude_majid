-- ============================================================
--  ATHAR — Site content sync (admin-edited About / policies / FAQ)
--  So content the admin edits is saved on the server and reaches everyone.
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================
create table if not exists public.site_content (
  id         text primary key,
  data       jsonb,
  updated_at timestamptz not null default now()
);

alter table public.site_content enable row level security;

drop policy if exists "content read" on public.site_content;
create policy "content read" on public.site_content
  for select using ( true );

drop policy if exists "content write admin" on public.site_content;
create policy "content write admin" on public.site_content
  for all using ( public.is_admin() ) with check ( public.is_admin() );

do $$
begin
  begin
    execute 'alter publication supabase_realtime add table public.site_content';
  exception when duplicate_object then null; when undefined_table then null;
  end;
end $$;
