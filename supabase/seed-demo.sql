-- ============================================================
--  ATHAR — DEMO SEED DATA
--  10 users · 10 campaigns · 5 partners (varied states + info)
--  HOW TO RUN: Supabase Dashboard → SQL Editor → paste → Run.
--  Every row is tagged so you can delete it all later (see CLEANUP at bottom).
--  Demo user password (all of them): Demo@1234
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1) USERS  →  auth.users (login accounts) + public.profiles (details)
--    The handle_new_user trigger creates a base profile row on insert;
--    we then fill in the rest by email.
-- ─────────────────────────────────────────────────────────────
insert into auth.users
  (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
   raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
   confirmation_token, recovery_token, email_change_token_new, email_change)
select '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
       u.email, crypt('Demo@1234', gen_salt('bf')), now(),
       '{"provider":"email","providers":["email"]}'::jsonb,
       jsonb_build_object('name', u.name), now(), now(), '', '', '', ''
from (values
  ('demo.layla@athar.demo'  , 'ليلى الأحمد'),
  ('demo.omar@athar.demo'   , 'عمر خليل'),
  ('demo.sara@athar.demo'   , 'سارة منصور'),
  ('demo.yousef@athar.demo' , 'يوسف حدّاد'),
  ('demo.rana@athar.demo'   , 'رنا العلي'),
  ('demo.khaled@athar.demo' , 'خالد ناصر'),
  ('demo.maya@athar.demo'   , 'مايا سليمان'),
  ('demo.tarek@athar.demo'  , 'طارق فارس'),
  ('demo.noor@athar.demo'   , 'نور شاهين'),
  ('demo.hiba@athar.demo'   , 'هبة كنعان')
) as u(email, name)
where not exists (select 1 from auth.users a where a.email = u.email);

update public.profiles p set
  name            = d.name,
  city            = d.city,
  country         = 'سوريا',
  phone           = d.phone,
  role            = d.role,
  status          = d.status,
  volunteer_hours = d.hours,
  profile_public  = true,
  ban_until       = case when d.status = 'banned' then now() + interval '30 days' else null end
from (values
  ('demo.layla@athar.demo'  , 'ليلى الأحمد'  , 'دمشق'     , '+963931000001', 'volunteer'         , 'approved', 48),
  ('demo.omar@athar.demo'   , 'عمر خليل'     , 'حلب'      , '+963931000002', 'campaign_organizer', 'approved', 36),
  ('demo.sara@athar.demo'   , 'سارة منصور'   , 'اللاذقية' , '+963931000003', 'volunteer'         , 'approved', 27),
  ('demo.yousef@athar.demo' , 'يوسف حدّاد'   , 'حمص'      , '+963931000004', 'volunteer'         , 'approved', 19),
  ('demo.rana@athar.demo'   , 'رنا العلي'    , 'طرطوس'    , '+963931000005', 'moderator'         , 'approved', 52),
  ('demo.khaled@athar.demo' , 'خالد ناصر'    , 'حماة'     , '+963931000006', 'volunteer'         , 'pending' , 0),
  ('demo.maya@athar.demo'   , 'مايا سليمان'  , 'دمشق'     , '+963931000007', 'volunteer'         , 'approved', 14),
  ('demo.tarek@athar.demo'  , 'طارق فارس'    , 'دير الزور', '+963931000008', 'volunteer'         , 'rejected', 0),
  ('demo.noor@athar.demo'   , 'نور شاهين'    , 'إدلب'     , '+963931000009', 'volunteer'         , 'banned'  , 8),
  ('demo.hiba@athar.demo'   , 'هبة كنعان'    , 'السويداء' , '+963931000010', 'volunteer'         , 'approved', 41)
) as d(email, name, city, phone, role, status, hours)
where p.email = d.email;

-- ─────────────────────────────────────────────────────────────
-- 2) CAMPAIGNS  (varied categories + statuses + an emergency one)
-- ─────────────────────────────────────────────────────────────
insert into public.campaigns
  (title, description, category, location, date, needed, volunteer_hours,
   status, emergency, creator_name, creator_phone, created_at, updated_at, completed_at)
select c.title, c.description, c.category, c.location, c.date::date, c.needed, c.hours,
       c.status, c.emergency, c.creator, c.phone, now(), now(),
       case when c.status = 'done' then now() else null end
from (values
  ('تنظيف شاطئ اللاذقية'        , 'حملة لتنظيف شاطئ المدينة من النفايات وإعادته نظيفًا للزوّار.'        , 'cleaning'   , 'اللاذقية' , '2026-07-20', 30, 4, 'approved'      , false, 'ليلى الأحمد', '+963931000001'),
  ('زراعة 500 شجرة في الغوطة'   , 'مبادرة بيئية لزراعة 500 شجرة مثمرة في الغوطة الشرقية.'               , 'planting'   , 'دمشق'     , '2026-08-05', 50, 3, 'approved'      , false, 'عمر خليل'   , '+963931000002'),
  ('دروس دعم لأطفال الأحياء'    , 'دروس تقوية مجانية في الرياضيات واللغة العربية لأطفال المرحلة الابتدائية.', 'education'  , 'حلب'      , '2026-07-28', 20, 5, 'under_process' , false, 'رنا العلي'  , '+963931000005'),
  ('حملة تبرّع بالدم'           , 'حملة تبرّع بالدم لدعم بنك الدم في المشفى الوطني.'                    , 'health'     , 'حمص'      , '2026-07-15', 40, 2, 'approved'      , false, 'يوسف حدّاد' , '+963931000004'),
  ('توزيع سلال غذائية'          , 'توزيع 300 سلة غذائية على العائلات الأكثر حاجة قبل العيد.'             , 'community'  , 'إدلب'     , '2026-06-10', 25, 3, 'done'          , false, 'هبة كنعان'  , '+963931000010'),
  ('ترميم حديقة الأطفال'        , 'إعادة تأهيل وترميم حديقة عامة وتجهيزها بألعاب آمنة للأطفال.'           , 'improvement', 'حماة'     , '2026-08-18', 15, 6, 'pending'       , false, 'خالد ناصر'  , '+963931000006'),
  ('استجابة طارئة للسيول'       , 'فريق طوارئ لمساعدة المتضرّرين من السيول وتأمين المستلزمات العاجلة.'    , 'emergency'  , 'دير الزور', '2026-07-12', 60, 4, 'approved'      , true , 'عمر خليل'   , '+963931000002'),
  ('تنظيف ضفاف نهر بردى'        , 'حملة لتنظيف ضفاف نهر بردى ورفع الأنقاض المتراكمة.'                   , 'cleaning'   , 'دمشق'     , '2026-08-22', 35, 4, 'approved'      , false, 'مايا سليمان', '+963931000007'),
  ('مكتبة متنقّلة للقرى'        , 'مكتبة متنقّلة توصل الكتب والأنشطة الثقافية لأطفال القرى البعيدة.'      , 'education'  , 'طرطوس'    , '2026-09-01', 12, 3, 'pending'       , false, 'سارة منصور' , '+963931000003'),
  ('تشجير كورنيس اللاذقية'      , 'زراعة أشجار الزينة على طول الكورنيش لتجميل الواجهة البحرية.'           , 'planting'   , 'اللاذقية' , '2026-05-30', 45, 3, 'archived'      , false, 'ليلى الأحمد', '+963931000001')
) as c(title, description, category, location, date, needed, hours, status, emergency, creator, phone)
where not exists (select 1 from public.campaigns x where x.title = c.title);

-- ─────────────────────────────────────────────────────────────
-- 3) PARTNERS  (varied types + approved/pending + featured)
-- ─────────────────────────────────────────────────────────────
insert into public.partners (org, contact, email, phone, type, msg, status, featured)
select p.org, p.contact, p.email, p.phone, p.type, p.msg, p.status, p.featured
from (values
  ('جمعية البيئة السورية'    , 'م. سامر يوسف'  , 'env@demo.org'    , '+963933000001', 'ngo' , 'نرغب بدعم حملات التشجير وتنظيف الشواطئ في الساحل السوري.'       , 'approved', true ),
  ('مؤسسة عطاء الخيرية'      , 'أ. هند العمر'   , 'ataa@demo.org'   , '+963933000002', 'ngo' , 'نوفّر سلالًا غذائية وكفالات للأسر المحتاجة عبر متطوّعيكم.'      , 'approved', false),
  ('شركة الأمل للمقاولات'    , 'م. باسل حمدان'  , 'amal@demo.org'   , '+963933000003', 'priv', 'مستعدّون لتمويل وترميم الحدائق والمرافق العامة كمسؤولية مجتمعية.', 'pending' , false),
  ('بلدية اللاذقية'          , 'مكتب العلاقات'  , 'city@demo.org'   , '+963933000004', 'gov' , 'تنسيق رسمي لتنظيم حملات النظافة والتشجير ضمن المدينة.'          , 'approved', true ),
  ('مبادرة أيادٍ بيضاء'      , 'م. لمى خوري'    , 'ayadi@demo.org'  , '+963933000005', 'ind' , 'مبادرة شبابية تطوّعية ترغب بالشراكة في الأنشطة التعليمية.'      , 'pending' , false)
) as p(org, contact, email, phone, type, msg, status, featured)
where not exists (select 1 from public.partners x where x.org = p.org);

-- ============================================================
--  ✅ DONE. To verify:
--    select name, city, status, volunteer_hours from public.profiles where email like '%@athar.demo';
--    select title, status, category from public.campaigns;
--    select org, type, status from public.partners;
-- ============================================================

-- ============================================================
--  🧹 CLEANUP — run this LATER to remove ALL demo data
--  (uncomment the lines below and Run)
-- ============================================================
-- delete from public.partners  where email like '%@demo.org';
-- delete from public.campaigns where creator_phone like '+96393100%';
-- delete from auth.users       where email like '%@athar.demo';   -- cascades to profiles
