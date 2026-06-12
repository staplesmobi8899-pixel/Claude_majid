# Phase 3 — Navigation Architecture: Audit & Plan

> audit + خطة فقط. لا كود قبل الاتفاق (بند 13/14 + القاعدة الذهبية).

## أ) الموجود حاليًا (audit)

### التنقّل
- **`goPage(name)`**: يخفي كل `.page`، يفعّل `#{name}Page` و`#nav-{name}`، `State.setPage`, يستدعي الـ renderer المناسب، `scrollTo(0,0)`. — هو «الراوتر» الحالي لكن المنطق متناثر بداخله.
- **`goBack()`**: `goPage(State.prevPage || 'home')` — **مستوى واحد فقط** (لا stack حقيقي).
- **`State`**: `currentPage`, `prevPage`, `detailCampId` — لا تاريخ تنقّل (history stack).

### المكوّنات
- **Navbar علوي ثابت**: شعار + زر لغة + زر خروج — **عام وليس context-aware** (لا عنوان ديناميكي/رجوع/أكشنات حسب الشاشة).
- **Bottom nav** (الحالي): `home · explore · create · profile · about · admin`(مخفي) — **6 أزرار**.
- **Admin sidebar** (`adm-sidebar`): drawer خاص بالأدمن (overlay + safe-area).
- **Modals**: `createModal` (+ auth/verify/onboarding overlays من Phase 2).
- **انتقالات**: `.page.active { animation: fadeIn }` بسيطة.

### الصفحات الحالية
`home · explore · create · detail · profile · about · admin`

---

## ب) الفجوات مقابل بريف Phase 3 (14)

| # | المطلوب | الحالة |
|---|---|---|
| 1 | Global nav (stack/nested/modal/deep-link/scalable) | ⚠️ مسطّح (goPage + prevPage واحد) |
| 2 | Bottom nav: **Home · Explore · Community · Notifications · Profile** | ❌ التبويبات الحالية مختلفة؛ **Community + Notifications غير موجودتين**؛ Create تبويب (المفروض FAB) |
| 3 | Header system (عنوان ديناميكي · رجوع · أكشنات · بحث) context-aware | ❌ navbar عام ثابت |
| 4 | Back logic (stack صحيح · لا dead-ends · swipe-back · إغلاق modals) | ⚠️ مستوى واحد |
| 5 | Responsive shell (portrait/landscape/tablet/desktop) | ⚠️ جزئي |
| 6 | RTL/LTR nav | ✅ غالبًا (logical props + lang toggle) |
| 7 | Transitions (fade/slide/upward · easing هادئ) | ⚠️ fade بسيط فقط |
| 8 | Drawer/sidebar (collapsible · overlay موبايل · fixed ديسكتوب) | ⚠️ موجود للأدمن فقط |
| 9 | Route management (مركزي · guards · auth-aware · role-based · protected) | ❌ لا راوتر مركزي؛ لا guards (goPage('admin') بلا حارس) |
| 10 | Error prevention (روابط ميتة · صفحات سوداء) | ⚠️ يحتاج sweep |
| 11 | مكوّنات (bottom nav · header · back · sidebar · sheet · FAB · tabs · breadcrumb) | ⚠️ بعضها موجود |
| 13 | audit · إزالة تكرار · توحيد | ⏳ (هذا التقرير) |
| 14 | العمود الفقري لكل الأنظمة المستقبلية | — يُبنى الآن |

---

## ج) المعمارية المقترحة

1. **`Router` (جديد، مصدر واحد):**
   - `ROUTES` معرّف مركزي: لكل route `{ render?, auth, roles, tab, title, type:'page'|'modal' }`.
   - `Router.go(name, params)` — يطبّق **guards** (auth-aware عبر `requireAuth`، role-based عبر `Permissions`)، يدير **stack** (`Router.stack`), يفعّل الصفحة، يحدّث الهيدر والتبويب.
   - `Router.back()` — يسحب من الـ stack (رجوع حقيقي متعدّد المستويات)، يغلق الـ modal لو مفتوح.
   - **`goPage(name)` يبقى wrapper رفيع يفوّض إلى `Router.go`** (توافق خلفي مع كل الـ `onclick="goPage(...)"`).
2. **Bottom nav جديد:** Home · Explore · Community · Notifications · Profile. **Create → FAB** عائم. About/Admin → عبر الهيدر/قائمة البروفايل.
3. **صفحتان جديدتان (هيكل + placeholder):** Community · Notifications — يتعبّى محتواهما في Phase 9/لاحقًا، لكن التنقّل يدمجهما الآن.
4. **Header system:** هيدر موحّد context-aware (عنوان + رجوع + أكشنات) يتكيّف حسب الـ route.
5. **Transitions:** slide/fade هادئ عبر التوكنات + cubic-bezier.
6. **Sidebar/shell:** تعميم الـ drawer + shell متجاوب (tablet/desktop).

---

## د) ترتيب البناء (دفعات مُتحقَّق منها + لينك)

| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **3.0** | `Router` + `ROUTES` + guards (auth/role) + stack — `goPage` يفوّض. بلا تغيير UI | منخفضة |
| **3.1** | Bottom nav جديد (5 تبويبات) + **Create FAB** + صفحتا Community/Notifications | متوسطة (UI) |
| **3.2** | Header system context-aware | متوسطة |
| **3.3** | Back/stack + transitions + swipe-back iOS + إغلاق modals | متوسطة |
| **3.4** | Sidebar/shell متجاوب (tablet/desktop) | متوسطة |
| **3.5** | Error-prevention sweep (روابط ميتة) + تلميع | منخفضة |

> كل دفعة: HTML+CSS+JS كوحدة → node --check + فحص الدوال + jsdom + لينك.
