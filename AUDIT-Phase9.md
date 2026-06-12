# Phase 9 — Community & Social Impact: Audit & Plan

> audit + خطة. لا كود قبل الاتفاق.

## أ) الموجود
- **`communityPage`:** stub فقط (hero + «قريباً»). route onEnter فارغ.
- **جاهز للبناء عليه:** `ReportService` (إشراف 8.7) · `NotificationService` (+broadcast) · `AchievementService` · leaderboards (admin) · `DiscoveryService` · رفع صور (`b64`) · توكنات/مكوّنات بطاقات.

## ب) المطلوب (17 بند) — مكثّف
Feed · Posts (صور/نص) · Impact Stories (before/after) · Reactions (3) · Comments (threaded-ready) · Volunteer Highlights · Groups (scaffold) · Auto-updates · Media · Moderation · Notifications · Responsive/RTL · مكوّنات معاد استخدامها · UX عاطفي.

## ج) المعمارية المقترحة
- **`CommunityService`** (DB: `athar_posts`): نموذج post {id, author, type(post|story|auto), text, media[], before/after, reactions{support,impact,appreciation:[userIds]}, comments[{id,author,text,date,parentId}], createdAt}. + add/getFeed/react/comment/remove + auto-update generator.
- **صفحة المجتمع** = تبويبات: **الموجز (Feed)** · **القصص (Stories)** · **الأبرز (Highlights)**.
- **مكوّنات:** post-card · story-card · reaction-bar · comment-list · highlight-card · media-grid — كلها بالتوكنات (هادئة، بلا آليات إدمان).
- **تكامل:** الإشعارات (reaction/comment) · الإشراف (report→ReportService) · البروفايل/الإنجازات/الساعات/leaderboard.

## د) دفعات البناء (متحقَّقة + لينك)
| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **9.0** | `CommunityService` + نموذج + auto-update generator + shell التبويبات + CSS البطاقات | منخفضة |
| **9.1** | Feed + إنشاء منشور (نص+صورة) + Reactions (3) | متوسطة |
| **9.2** | Comments (threaded-ready) + report + تكامل الإشعارات | متوسطة |
| **9.3** | Impact Stories (before/after) + Volunteer Highlights + auto-updates بالموجز | متوسطة |
| **9.4** | Responsive/RTL + Groups scaffold + تلميع | منخفضة |

> كل دفعة: node --check + فحص الدوال + jsdom + لينك. التجميل النهائي → Phase 11.

## هـ) قرارات
1. **العمق الآن:** أساسي كامل (feed+posts+reactions+comments+stories+highlights+auto، مع Groups scaffold) أم مينمال (feed+posts+reactions)؟
2. **شكل الـ Reactions:** البريف يقترح ❤️🌱👏 — بس إنت بتفضّل بلا إيموجي. نستخدم أيقونات/تسميات نظيفة أم الإيموجي الثلاثة؟
