-- ============================================================
--  ATHAR — Enable Supabase Realtime for 100% live sync
--
--  The app subscribes to live DB changes on these tables so every open
--  device updates within ~1s of any change (admin approvals, new campaigns,
--  joins, reactions, notifications...) with no manual reload.
--
--  This adds each table to the realtime publication. Safe to re-run:
--  tables already enabled (or missing) are skipped silently.
--
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
-- ============================================================

do $$
declare t text;
begin
  foreach t in array array[
    'profiles', 'campaigns', 'campaign_participants', 'posts',
    'post_reactions', 'post_comments', 'communities', 'community_members',
    'notifications', 'partners'
  ]
  loop
    begin
      execute format('alter publication supabase_realtime add table public.%I', t);
    exception
      when duplicate_object then null;   -- already enabled
      when undefined_table then null;    -- table doesn't exist in this project
    end;
  end loop;
end $$;

-- Verify which tables are realtime-enabled:
-- select schemaname, tablename from pg_publication_tables
-- where pubname = 'supabase_realtime' order by tablename;
