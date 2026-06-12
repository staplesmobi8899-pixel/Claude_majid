# Phase 8 — Admin Dashboard & Control System: Audit & Plan

> audit + خطة. لا كود قبل الاتفاق (القاعدة الذهبية + بند 15).

## أ) الموجود (audit — مبني ~60%)
- **Shell حديث:** `#adminPage` → header (toggle/title/global search/back) + `adm-sidebar` (drawer موبايل، static على >1400px) + overlay + `adm-content`.
- **6 أقسام (panels)** عبر `admSwitchPanel`: Dashboard · Users · Campaigns · Partners · Analytics · Notifications (مع بادجات عدد).
- **Dashboard:** `admRenderOverview` — شبكة إحصاءات (`adm-stat-card`) + إجراءات سريعة + Pending Reviews + Recent Activity.
- **Users:** `admRenderUsers` — بحث + chips (pending/approved/rejected/banned) + بطاقات + `admViewUser` (modal: approve/reject/ban 3·7·30).
- **Campaigns:** `admRenderCampaigns` — بحث + chips حالات + `admViewCamp`/`admEditCamp`/`saveCampEdit`.
- **Partners:** `admRenderPartners` + `admViewPartner` (عرض فقط — **بلا approve/reject**).
- **Analytics:** `admRenderAnalytics` — فئات + Top Volunteers + المدن (أشرطة).
- **Notifications:** `admRenderNotifications` — قائمة المعلّقات (مستخدمون/حملات/شراكات).
- **مكوّنات:** `admStatusChip` · `admEmpty` · `admTimeAgo` · `admBar` · `admOpenModal`/`admCloseModal` · `adm-modal`.
- **الصلاحيات:** `Permissions` (roleOf/meta/can/hasRole/isAdmin/canManageCamp/canViewProfile) + `CONFIG.ROLES` (guest·volunteer·campaign_leader·partner·moderator·admin).

## ب) الفجوات مقابل البريف (16 نظام)
| # | المطلوب | الحالة |
|---|---|---|
| 1 | Overview (engagement · pending) | ⚠️ أساسي موجود، يوسّع |
| 2 | User mgmt (بحث name/email/phone/city · suspend · **edit** · **assign role**) | ⚠️ ناقص تعديل/أدوار |
| 3 | Campaign mgmt (visibility · **archive** · participation · analytics) | ⚠️ ناقص أرشفة/مشاركون |
| 4 | Partnership mgmt (**approve** · **featured** · logos · analytics) | ❌ عرض فقط |
| 5 | Community moderation (reports scaffold) | ❌ |
| 6 | Analytics (growth · trends · top cities/vols · categories) | ⚠️ أساسي |
| 7 | Notifications center (**send announcements/broadcast**) | ❌ |
| 8 | Content mgmt (About/FAQ/policies/featured editable) | ❌ |
| 9 | Roles (6: **Super Admin**·Admin·Moderator·Partner·Organizer·Volunteer) modular | ⚠️ 5 بلا Super Admin |
| 10–12 | Responsive · Sidebar · RTL/LTR | ⚠️ موجود، sweep |
| 13 | مكوّنات معاد استخدامها (tables/badges/widgets/filters) | ⚠️ بعضها |
| 15 | تنظيف: emoji · inline styles بالمودال · توحيد · access في كل handler | ⏳ |

## ج) أهم المشاكل (من الجرد)
- نصوص إنجليزية ثابتة (nav labels/placeholders) — مو عبر `t()`.
- **emoji** كتير بالـ UI (placeholders/empty/status) — ضد الهوية المينمال.
- **inline styles** بأزرار المودال (approve/reject/ban) — لازم classes.
- **Partner requests بلا approve/reject** + لا حقل status.
- لا **assign role** · لا **archive** للحملات · لا **broadcast**.
- access check مش بكل handler (بعضها بلا `Permissions`).
- modal backdrop ما بيسكّر إلا بالضغط الدقيق.

## د) ترتيب البناء (دفعات متحقَّق منها + لينك)
| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **8.0** | الأساس: أدوار 6 modular (+Super Admin) · i18n لكل نصوص الأدمن · Settings nav+panel · تنظيف emoji/inline→classes · backdrop-close · توست بكل أكشن · PartnerService(status+approve/reject/feature) · access gating موحّد | منخفضة |
| **8.1** | User Management: بحث (name/email/phone/city) · suspend · **edit user** · **assign role** · activity | متوسطة |
| **8.2** | Campaign Management: إصلاح edit · **archive** · visibility · participation · per-camp analytics | متوسطة |
| **8.3** | Partnership Management: approve/reject · **featured** · logos (ربط بخانات About) · analytics | متوسطة |
| **8.4** | Analytics: growth · trends · top cities/vols · categories · impact widgets | متوسطة |
| **8.5** | Notifications Center: **broadcast/announcements** · إدارة التنبيهات | متوسطة |
| **8.6** | Content Mgmt (أساسي): About/FAQ/policies/featured قابلة للتعديل وتُخزَّن بالـ DB | متوسطة–عالية |
| **8.7** | Community Moderation (scaffold): reports queue + أكشنات إشراف (بلا feed) | منخفضة |
| **8.8** | Responsive/RTL/تلميع وظيفي (مو التصميم النهائي) | منخفضة |

> كل دفعة: HTML+CSS+JS كوحدة → node --check + فحص الدوال + jsdom + لينك. التجميل النهائي → Phase 11.

## هـ) قرارات للاتفاق
1. **نطاق إدارة المحتوى (#8):** أساسي (About/FAQ/سياسات/مميّزة قابلة للتعديل) أم CMS كامل لكل أقسام الرئيسية؟
2. **emoji الأدمن:** نستبدلها بأيقونات/نصوص مينمال نظيفة (متناسق/premium) أم نبقيها؟
3. **الأدوار:** نعتمد 6 أدوار + واجهة **assign role**، أم نبقي 5 ونضيف تسميات فقط؟
4. **البدء من 8.0** (موصى).
