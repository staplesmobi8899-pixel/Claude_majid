# Phase 6 — Profile System: Audit & Plan

> audit + خطة. لا كود قبل الاتفاق (بند 14 + القاعدة الذهبية).

## أ) الموجود (audit)
- **`profilePage`:** غلاف + أفاتار (`#profileAva`) + اسم/مدينة (`#profileName/#profileLoc`) + زر «تغيير الصورة» · بانر الحالة · إحصاءات 3 (`sH` ساعات · `sA` أنشطة · `sB` شارات) · قائمة `menu-card` بأقسام منسدلة: معلومات شخصية (`infoItems`) · صورة هوية (`idPhotoBox`) · حملاتي (`profileCampsBox`→renderMyCamps) · سجل الساعات (`hoursBox`) · **المحفوظات** (`savedBox`→renderSaved) · Admin (للأدمن) · خروج.
- **`renderProfile`:** يملأ الاسم/المدينة/الأفاتار/الإحصاءات + الأقسام.
- **`uploadAvatar`:** رفع صورة الأفاتار (مع `requireAuth`).
- **نموذج المستخدم:** volunteerHours · activitiesJoined · achievements(رقم) · joinedCamps · savedCampaigns · role · verification · banned.

## ب) الفجوات مقابل البريف (15)
| # | المطلوب | الحالة |
|---|---|---|
| 1 | بروفايل premium (دور · bio · شارات · history · progress) | ⚠️ أساسي |
| 2 | معلومات شخصية **بوضع تعديل** (+validation/save states) | ❌ عرض فقط |
| 3 | إحصاءات أثر (مكتملة · مدن · streak · score) | ⚠️ 3 فقط |
| 4 | **نظام إنجازات** (تعريفات · فتح · شارات) | ❌ رقم فقط |
| 5 | **Activity timeline** | ❌ |
| 6 | **شهادات** (عرض/تنزيل/مشاركة/تحقّق — بنية) | ❌ |
| 7 | المحفوظات | ✅ (Phase 5) |
| 8 | **صفحة إعدادات** (لغة · داكن · خصوصية · إشعارات · دعم · سياسات) | ⚠️ لغة فقط |
| 9 | صورة البروفايل (رفع/حذف/تحديث · bottom sheet) | ⚠️ رفع فقط |
| 12 | مكوّنات (stat/achievement cards · timeline · editable fields · upload) | ⚠️ بعضها |
| 14 | audit · أزرار ميتة · توحيد | ⏳ (هذا التقرير) |
| 15 | موصول بـ (حملات/ساعات/أنالتكس/leaderboard/إنجازات/شهادات) | ⚠️ جزئي |

## ج) المعمارية المقترحة
1. **`AchievementService`:** `CONFIG.ACHIEVEMENTS` (تعريفات: مفتاح · اسم · أيقونة · شرط) + `evaluate(user)` يفتح الإنجازات تلقائيًا (First Campaign · 10 Hours · Community Leader · Top Volunteer · Consistency · Environmental · City Contributor) + يخزّن `user.achievements` (مصفوفة مفاتيح) + إشعار عند الفتح.
2. **`StatsService`:** إحصاءات محسوبة من البيانات الموجودة — completed · cities impacted · streak · contribution score (موصولة بالحملات/الساعات).
3. **`CertificateService` (بنية):** شهادة لكل حملة مكتملة شارك بها — عرض/تنزيل/مشاركة لاحقًا.
4. **مكوّنات موحّدة:** stat-card · achievement-card · timeline-item · editable-field · settings-item · upload-sheet.
5. **نموذج المستخدم:** + `bio` · `achievements:[]`(مصفوفة) · `certificates:[]`.

## د) ترتيب البناء (دفعات مُتحقَّق منها + لينك)
| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **6.0** | الأساس: AchievementService + StatsService + CertificateService + حقول النموذج (bio/achievements[]/certificates[]) — refactor، تغيير UI طفيف | منخفضة |
| **6.1** | البروفايل premium: هيدر (أفاتار/اسم/دور/مدينة/bio) + شبكة إحصاءات + **شارات الإنجازات** + progress | متوسطة |
| **6.2** | تعديل المعلومات (edit mode + save/validation) + صورة البروفايل (رفع/حذف عبر bottom sheet) | متوسطة |
| **6.3** | **سجل النشاط (timeline)** + الشهادات (عرض) | متوسطة |
| **6.4** | **صفحة الإعدادات** (لغة · وضع داكن · خصوصية · إشعارات · دعم · سياسات · خروج) | متوسطة |

## هـ) قرار للاتفاق
- **الوضع الداكن (#8):** بنية فقط (data-theme + زر، بدون ثيم داكن كامل الآن) أم ثيم داكن كامل؟ (الكامل = عمل كبير لكل الشاشات.)
