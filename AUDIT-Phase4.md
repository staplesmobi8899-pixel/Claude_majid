# Phase 4 — Home & Explore: Audit & Plan

> audit + خطة فقط. لا كود قبل الاتفاق (بند 15 + القاعدة الذهبية).

## أ) الموجود (audit)
- **Home (`homePage`):** هيرو (forest + glows + eyebrow/title/sub + CTA→explore) · 4 عدّادات أثر (`cUsers/cCamps/cHours/cCities`) · قسم واحد «availCamps» → `#homeGrid`.
- **Explore (`explorePage`):** header (عنوان/وصف) · شبكة واحدة `#exploreGrid`. **بلا بحث/فلترة/فئات/فرز.**
- **`renderCampaigns()`:** `CampaignService.getVisible()` → `campCardHTML` لكل حملة → يحقن نفس الـ HTML في `homeGrid` و`exploreGrid`. حالة فارغة بسيطة (أيقونة+نص). لا تحميل.
- **`campCardHTML(c)`:** صورة/`camp-img-fallback` + شارة حالة + شارة فئة + عنوان/وصف/موقع/تاريخ/تقدّم% + زر انضمام (حالات: done/rejected/full/approved/joined).
- **`CONFIG.CAMP_CATEGORIES`:** cleaning · planting · improvement · support · education · event (6).
- **`CONFIG.CAUSES`** (من 2.6): environment · education · health · relief · community · culture · children · elderly (للاهتمامات/onboarding).

## ب) الفجوات مقابل بريف Phase 4 (16)
| # | المطلوب | الحالة |
|---|---|---|
| 1 | Home (تحية شخصية · featured · nearby · trending · community highlights · quick actions · upcoming) | ⚠️ عدّادات + قائمة واحدة فقط |
| 2 | Explore ديناميكي (فئات/مدن/trending/منظمات) | ❌ شبكة ثابتة |
| 3 | Discovery (فلترة فئة/مدينة · بحث · tags · فرز · popularity · nearby · توصيات) | ❌ لا شيء |
| 4 | Search (فوري · partial · recent · empty/loading) | ❌ لا شيء |
| 5 | Featured cards (سينمائية) | ⚠️ بطاقة عادية |
| 6 | Nearby (بنية جاهزة للموقع) | ❌ |
| 7 | Categories system (chips أنيقة) | ⚠️ بيانات موجودة، لا UI |
| 8 | Community highlights (top volunteers · active cities · milestones) | ❌ |
| 9 | Empty states (مشجّعة) | ⚠️ بسيطة |
| 10 | Loading (skeletons) | ❌ |
| 13 | مكوّنات (card · chip · search bar · filter sheet · stat card · quick actions · counters) | ⚠️ card فقط |

## ج) المعمارية المقترحة
1. **`DiscoveryService` (جديد):** مصدر واحد للاستعلام — `query({ search, category, city, sort })` يرجّع حملات مفلترة/مرتّبة. + `featured()`, `trending()`, `nearby(city)`, `recommended(user)` (تعتمد user.interests). + `cities()` (مشتقّة من الحملات).
2. **مكوّنات موحّدة (reusable):** `campCardHTML` (تحسين سينمائي + variant featured) · `categoryChip` · `searchBar` · `filterSheet` · `statCard` · `skeleton` · `emptyState`.
3. **Home** يُعاد بناؤه كأقسام: تحية شخصية → featured (carousel/banner) → فئات (chips) → trending/nearby → عدّادات أثر (موجودة) → community highlights → quick actions.
4. **Explore** = بحث فوري + chips فئات + فلتر مدينة + فرز + شبكة نتائج + skeleton + empty.

## د) ترتيب البناء (دفعات مُتحقَّق منها + لينك)
| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **4.0** | `DiscoveryService` + توحيد البطاقة + skeleton/empty مكوّنات (refactor، تغيير بصري طفيف) | منخفضة |
| **4.1** | Explore: بحث فوري + chips فئات + فلتر مدينة + فرز + حالات | متوسطة |
| **4.2** | Home: تحية + featured + فئات + trending/nearby + quick actions + community highlights | متوسطة–عالية |
| **4.3** | Skeletons + empty states + responsive/RTL sweep + تلميع عاطفي | متوسطة |

## هـ) قراران للاتفاق
1. **تصنيف الفئات:** أبقي `CAMP_CATEGORIES` الحالية (أنشطة) كما هي، أم أوسّعها/أحاذيها مع أمثلة البريف (Environment/Education/Health/Community/Youth/Sustainability/Food Aid/Animal Care)؟ (تغيير التصنيف يؤثّر على حملات موجودة.)
2. **من وين نبدأ:** 4.0 الأساس (موصى) أم 4.1 Explore مباشرة؟
