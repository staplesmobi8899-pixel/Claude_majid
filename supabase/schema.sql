-- ============================================================
--  ATHAR — Supabase schema (Phase 14: backend migration)
--  Paste this whole file into Supabase → SQL Editor → Run.
--  Safe to re-run (uses IF NOT EXISTS / CREATE OR REPLACE).
-- ============================================================

-- Allow functions to reference tables created later in this script
set check_function_bodies = off;

-- ---------- Helper: is the current user an admin? ----------
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'super_admin')
  );
$$;

-- ============================================================
--  PROFILES  (extends auth.users)
-- ============================================================
create table if not exists public.profiles (
  id              uuid primary key references auth.users(id) on delete cascade,
  name            text,
  email           text,
  phone           text,
  city            text,
  country         text,
  bio             text,
  profile_pic     text,
  dob             date,
  rejection_reason text,
  role            text not null default 'volunteer',   -- volunteer | campaign_leader | partner | moderator | admin
  status          text not null default 'pending',     -- pending | approved | rejected | banned
  ban_until       timestamptz,
  volunteer_hours numeric not null default 0,
  profile_public  boolean not null default false,
  saved_campaigns uuid[] not null default '{}',
  saved_posts     uuid[] not null default '{}',
  created_at      timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles read" on public.profiles;
create policy "profiles read" on public.profiles
  for select using ( true );           -- profiles are readable (names masked in the UI)

drop policy if exists "profiles insert self" on public.profiles;
create policy "profiles insert self" on public.profiles
  for insert with check ( auth.uid() = id );

drop policy if exists "profiles update self or admin" on public.profiles;
create policy "profiles update self or admin" on public.profiles
  for update using ( auth.uid() = id or public.is_admin() );

-- Auto-create a profile row when a new auth user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
--  CAMPAIGNS
-- ============================================================
create table if not exists public.campaigns (
  id              uuid primary key default gen_random_uuid(),
  title           text not null,
  description     text,
  category        text,
  location        text,
  date            date,
  needed          int not null default 1,
  volunteer_hours numeric not null default 2,
  status          text not null default 'pending',  -- pending|approved|under_process|done|rejected|archived
  emergency       boolean not null default false,
  community       boolean not null default false,
  created_by      uuid references public.profiles(id) on delete set null,
  creator_name    text,
  creator_phone   text,
  img             text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  completed_at    timestamptz
);

alter table public.campaigns enable row level security;

-- Public can see live campaigns; creators/admins see their own (incl. pending/rejected)
drop policy if exists "campaigns read" on public.campaigns;
create policy "campaigns read" on public.campaigns
  for select using (
    status in ('approved','under_process','done')
    or created_by = auth.uid()
    or public.is_admin()
  );

drop policy if exists "campaigns insert" on public.campaigns;
create policy "campaigns insert" on public.campaigns
  for insert with check ( auth.uid() = created_by );

drop policy if exists "campaigns update owner or admin" on public.campaigns;
create policy "campaigns update owner or admin" on public.campaigns
  for update using ( created_by = auth.uid() or public.is_admin() );

drop policy if exists "campaigns delete admin" on public.campaigns;
create policy "campaigns delete admin" on public.campaigns
  for delete using ( public.is_admin() );

-- ---------- Campaign participants (join table) ----------
create table if not exists public.campaign_participants (
  campaign_id uuid references public.campaigns(id) on delete cascade,
  user_id     uuid references public.profiles(id) on delete cascade,
  attendance  text,                       -- attended | absent | null
  joined_at   timestamptz not null default now(),
  primary key (campaign_id, user_id)
);

alter table public.campaign_participants enable row level security;

drop policy if exists "participants read" on public.campaign_participants;
create policy "participants read" on public.campaign_participants
  for select using ( true );

drop policy if exists "participants join self" on public.campaign_participants;
create policy "participants join self" on public.campaign_participants
  for insert with check ( auth.uid() = user_id );

drop policy if exists "participants leave self" on public.campaign_participants;
create policy "participants leave self" on public.campaign_participants
  for delete using ( auth.uid() = user_id or public.is_admin() );

drop policy if exists "participants update admin" on public.campaign_participants;
create policy "participants update admin" on public.campaign_participants
  for update using ( public.is_admin() );

-- ============================================================
--  COMMUNITY POSTS
-- ============================================================
create table if not exists public.posts (
  id           uuid primary key default gen_random_uuid(),
  type         text not null default 'post',  -- post | story
  author_id    uuid references public.profiles(id) on delete cascade,
  text         text,
  media        text[] not null default '{}',
  before_img   text,
  after_img    text,
  camp_id      uuid references public.campaigns(id) on delete set null,
  community_id uuid,
  created_at   timestamptz not null default now()
);

alter table public.posts enable row level security;

drop policy if exists "posts read" on public.posts;
create policy "posts read" on public.posts for select using ( true );

drop policy if exists "posts insert self" on public.posts;
create policy "posts insert self" on public.posts
  for insert with check ( auth.uid() = author_id );

drop policy if exists "posts delete owner or admin" on public.posts;
create policy "posts delete owner or admin" on public.posts
  for delete using ( author_id = auth.uid() or public.is_admin() );

-- ---------- Reactions ----------
create table if not exists public.post_reactions (
  post_id uuid references public.posts(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  kind    text not null,                  -- like | support
  primary key (post_id, user_id, kind)
);
alter table public.post_reactions enable row level security;
drop policy if exists "reactions read" on public.post_reactions;
create policy "reactions read" on public.post_reactions for select using ( true );
drop policy if exists "reactions write self" on public.post_reactions;
create policy "reactions write self" on public.post_reactions
  for all using ( auth.uid() = user_id ) with check ( auth.uid() = user_id );

-- ---------- Comments ----------
create table if not exists public.post_comments (
  id        uuid primary key default gen_random_uuid(),
  post_id   uuid references public.posts(id) on delete cascade,
  author_id uuid references public.profiles(id) on delete cascade,
  text      text not null,
  parent_id uuid,
  created_at timestamptz not null default now()
);
alter table public.post_comments enable row level security;
drop policy if exists "comments read" on public.post_comments;
create policy "comments read" on public.post_comments for select using ( true );
drop policy if exists "comments insert self" on public.post_comments;
create policy "comments insert self" on public.post_comments
  for insert with check ( auth.uid() = author_id );
drop policy if exists "comments delete owner or admin" on public.post_comments;
create policy "comments delete owner or admin" on public.post_comments
  for delete using ( author_id = auth.uid() or public.is_admin() );

-- ============================================================
--  COMMUNITIES (user-created groups)
-- ============================================================
create table if not exists public.communities (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  cover       text,
  private     boolean not null default false,
  owner       uuid references public.profiles(id) on delete cascade,
  pinned      uuid[] not null default '{}',
  created_at  timestamptz not null default now()
);
alter table public.communities enable row level security;
drop policy if exists "communities read" on public.communities;
create policy "communities read" on public.communities for select using ( true );
drop policy if exists "communities insert self" on public.communities;
create policy "communities insert self" on public.communities
  for insert with check ( auth.uid() = owner );
drop policy if exists "communities update owner or admin" on public.communities;
create policy "communities update owner or admin" on public.communities
  for update using ( owner = auth.uid() or public.is_admin() );
drop policy if exists "communities delete owner or admin" on public.communities;
create policy "communities delete owner or admin" on public.communities
  for delete using ( owner = auth.uid() or public.is_admin() );

create table if not exists public.community_members (
  community_id uuid references public.communities(id) on delete cascade,
  user_id      uuid references public.profiles(id) on delete cascade,
  status       text not null default 'member',   -- member | pending
  joined_at    timestamptz not null default now(),
  primary key (community_id, user_id)
);
alter table public.community_members enable row level security;
drop policy if exists "members read" on public.community_members;
create policy "members read" on public.community_members for select using ( true );
drop policy if exists "members join self" on public.community_members;
create policy "members join self" on public.community_members
  for insert with check ( auth.uid() = user_id );
drop policy if exists "members update owner or admin" on public.community_members;
create policy "members update owner or admin" on public.community_members
  for update using (
    public.is_admin() or
    exists (select 1 from public.communities c where c.id = community_id and c.owner = auth.uid())
  );
drop policy if exists "members delete self or owner" on public.community_members;
create policy "members delete self or owner" on public.community_members
  for delete using (
    auth.uid() = user_id or public.is_admin() or
    exists (select 1 from public.communities c where c.id = community_id and c.owner = auth.uid())
  );

-- ============================================================
--  NOTIFICATIONS
-- ============================================================
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references public.profiles(id) on delete cascade,
  ar         text,
  en         text,
  type       text,
  read       boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;
drop policy if exists "notifs read own" on public.notifications;
create policy "notifs read own" on public.notifications
  for select using ( user_id = auth.uid() or public.is_admin() );
drop policy if exists "notifs insert" on public.notifications;
create policy "notifs insert" on public.notifications
  for insert with check ( auth.uid() is not null );   -- any signed-in user/action can notify
drop policy if exists "notifs update own" on public.notifications;
create policy "notifs update own" on public.notifications
  for update using ( user_id = auth.uid() );

-- ============================================================
--  PARTNERS  &  REPORTS
-- ============================================================
create table if not exists public.partners (
  id        uuid primary key default gen_random_uuid(),
  org       text, contact text, email text, phone text, type text, msg text,
  status    text not null default 'pending',
  featured  boolean not null default false,
  logo      text,
  created_at timestamptz not null default now()
);
alter table public.partners enable row level security;
drop policy if exists "partners insert any" on public.partners;
create policy "partners insert any" on public.partners for insert with check ( true );
drop policy if exists "partners read admin" on public.partners;
create policy "partners read admin" on public.partners
  for select using ( public.is_admin() or featured = true );
drop policy if exists "partners write admin" on public.partners;
create policy "partners write admin" on public.partners
  for update using ( public.is_admin() );

create table if not exists public.reports (
  id          uuid primary key default gen_random_uuid(),
  target_type text, target_id text, reason text,
  reporter_id uuid references public.profiles(id) on delete set null,
  status      text not null default 'open',
  created_at  timestamptz not null default now()
);
alter table public.reports enable row level security;
drop policy if exists "reports insert auth" on public.reports;
create policy "reports insert auth" on public.reports
  for insert with check ( auth.uid() is not null );
drop policy if exists "reports admin" on public.reports;
create policy "reports admin" on public.reports
  for select using ( public.is_admin() );
drop policy if exists "reports update admin" on public.reports;
create policy "reports update admin" on public.reports
  for update using ( public.is_admin() );

-- ============================================================
--  STORAGE BUCKETS  (avatars, campaign images, post media, community covers)
-- ============================================================
insert into storage.buckets (id, name, public)
values
  ('avatars','avatars',true),
  ('campaigns','campaigns',true),
  ('posts','posts',true),
  ('communities','communities',true)
on conflict (id) do nothing;

-- Anyone can read public buckets; any signed-in user can upload
drop policy if exists "storage read" on storage.objects;
create policy "storage read" on storage.objects
  for select using ( bucket_id in ('avatars','campaigns','posts','communities') );

drop policy if exists "storage upload" on storage.objects;
create policy "storage upload" on storage.objects
  for insert with check (
    bucket_id in ('avatars','campaigns','posts','communities')
    and auth.uid() is not null
  );

drop policy if exists "storage update own" on storage.objects;
create policy "storage update own" on storage.objects
  for update using ( owner = auth.uid() or public.is_admin() );

drop policy if exists "storage delete own" on storage.objects;
create policy "storage delete own" on storage.objects
  for delete using ( owner = auth.uid() or public.is_admin() );

-- ============================================================
--  AFTER RUNNING: make yourself admin (replace the email)
--    update public.profiles set role='admin', status='approved'
--    where email = 'YOUR_EMAIL_HERE';
-- ============================================================

-- ============================================================
--  REPORTS  (user-filed reports; admin-only read/update)
-- ============================================================
create table if not exists public.reports (
  id           uuid primary key default gen_random_uuid(),
  target_type  text,
  target_id    text,
  reason       text,
  note         text,
  reporter_id  uuid references public.profiles(id) on delete set null,
  status       text not null default 'open',
  created_at   timestamptz not null default now()
);
alter table public.reports enable row level security;
drop policy if exists "reports insert" on public.reports;
create policy "reports insert" on public.reports for insert with check ( auth.uid() is not null );
drop policy if exists "reports read admin" on public.reports;
create policy "reports read admin" on public.reports for select using ( public.is_admin() );
drop policy if exists "reports update admin" on public.reports;
create policy "reports update admin" on public.reports for update using ( public.is_admin() );
