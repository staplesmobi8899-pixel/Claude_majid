# Phase 10 — Real-Time, Notifications & Live Interactions: Audit & Plan

> audit + خطة. القيد: تطبيق ملف واحد offline (localStorage، بلا backend).

## أ) الموجود
- **NotificationService:** add/getFor/unreadCount/markAllRead/**broadcast** + أنواع (approval/campaign/join/achievement/community/announcement…).
- **الجرس** (`updateBell`/`bellBadge`) + صفحة إشعارات (`renderNotifications` قائمة بسيطة).
- **AchievementService** (فتح تلقائي + إشعار) · **StatsService** (إحصاءات محسوبة) · **سجل النشاط** (بروفايل 6.3) · حالة الحملة ديناميكية.
- **إعدادات الإشعارات:** مفتاح on/off واحد (`notifPref`).

## ب) القيد التقني (مهم)
لا يوجد سيرفر/شبكة في الملف الواحد، فـ **Supabase realtime · Push (FCM/APNs) · Email** لا يمكن تنفيذها فعليًا الآن. الحل: **بنية محوّلات (adapters) جاهزة** + سلوك حيّ حقيقي بما يسمح به المتصفح.

## ج) ما يُبنى فعليًا (client-side حيّ + scaffolds)
1. **مركز إشعارات مطوّر:** أيقونات لكل نوع · تجميع (اليوم/أقدم) · فلاتر · «تعليم الكل مقروء» · نقر→تنقّل · يحترم التفضيلات.
2. **LiveService (حيّ حقيقي):** مزامنة **عبر التبويبات** عبر `storage` events + **polling** خفيف داخل الجلسة لتحديث الجرس/الموجز/التفاصيل → إحساس حيّ بلا backend.
3. **تفضيلات إشعارات ذكية:** مفاتيح لكل نوع + **الوضع الصامت (Quiet)**؛ `NotificationService.add` يحترمها.
4. **محوّلات backend (scaffold أمين):** `RealtimeService` (محوّل localStorage الآن · فتحة Supabase) · `PushService` (Web Notifications API فعلي + بنية FCM/APNs) · `EmailService` (طابور/سجل بقالب أثر — بلا إرسال فعلي).
5. **حضور خفيف (Presence):** «نشِط الآن» محسوب من نبضة lastActive (مينمال).
6. **حالة حملة حيّة:** تحديث لطيف للأماكن المتبقية/التقدّم.

## د) دفعات
| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **10.0** | LiveService (storage-sync + polling) + RealtimeService/PushService/EmailService scaffolds + Presence | منخفضة |
| **10.1** | مركز إشعارات مطوّر (أنواع/تجميع/فلاتر/تنقّل/تعليم مقروء) | متوسطة |
| **10.2** | تفضيلات إشعارات ذكية (per-type + Quiet) + احترامها بالإرسال + Push opt-in | متوسطة |
| **10.3** | تكامل حيّ: الموجز/الجرس/التفاصيل + presence + تلميع RTL/responsive | متوسطة |

## هـ) قرار
- النهج: **client-side حيّ + بنية backend جاهزة** (موصى، الممكن فعليًا) أم محاولة Supabase حقيقي (يتطلّب سيرفر/مفاتيح ويكسر مبدأ الملف الواحد offline)؟
