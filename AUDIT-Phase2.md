# Phase 2 — Authentication: Audit & Architecture Proposal

> تقرير **audit + خطة** فقط. لا كود قبل الاتفاق (بند 13/14 من البريف + القاعدة الذهبية).

## أ) الموجود حاليًا (audit دقيق)

### الشاشات/الواجهات
- **`#loginScreen`**: شعار + tagline + زرّان (انضم / تسجيل دخول) يفتحان modals. (welcome مبدئي).
- **`#loginModal`** (bottom-sheet `.modal-sheet`): email + password → `doLogin(event)`.
- **`#signupModal`** (bottom-sheet): name, phone, email, password, country(select), city, dob, profilePic(file), **idPhoto(file, required)**, special(textarea) → `doSignup(event)`.

### المنطق (JS)
- **`doLogin(e)`**: أدمن (CONFIG.ADMIN_EMAIL/PASS ثابتة) + مستخدم عادي (دخول بـ email **أو** phone **أو** name + password)؛ يرفض `status==='rejected'`؛ يحفظ الجلسة.
- **`doSignup(e)`**: `Validators.signup` → فحص تكرار الإيميل → `Models.createUser` (status: **pending**) → حفظ → **toast فقط** (لا شاشة).
- **`doLogout` / `enterApp`**: تبديل الشاشات + navbar + bottomNav + nav-admin.
- **`State`**: `cu`, `isAdmin` (مشتقّة من `email===ADMIN_EMAIL`), `setUser`. الجلسة في `localStorage` (`athar_session`).
- **`UserService`**: getAll/getById/getByEmail/getByPhone/save/updateById/**approve/reject** ✅ (طبقة خدمة سليمة).
- **`Models.createUser`**: status `pending`، بدون حقل **role**.
- **`Validators`**: isEmail/isPhone/isRequired/isPassword(**8+**)/isName + signup/login. ⚠️ تعارض: HTML password `minlength="6"` بينما Validator يطلب 8.
- **`CONFIG`**: DB_KEYS، USER_STATUS (pending/approved/rejected)، CAMP_CATEGORIES. **لا ROLES**، لا verification.

### مكوّنات قابلة لإعادة الاستخدام موجودة
`.field`, `.field-row`, `.form-grid`, `.modal-sheet/overlay/handle/title`, `.submit-btn`, `.dark-input` + `setLoading()`, `showFieldError()`, `clearFieldErrors()`.

---

## ب) الفجوات مقابل متطلبات Phase 2 (14 نظام)

| # | المطلوب | الحالة |
|---|---|---|
| 1 | Welcome Experience | ⚠️ مبدئي (شعار+tagline+CTA)، بلا onboarding preview/عاطفة |
| 2 | Login (email/phone/remember/states) | ⚠️ email يعمل، phone جزئي، **لا remember me**، success state ناقص |
| 3 | Registration (+confirm password) | ⚠️ موجود لكن modal طويل، **لا confirm password**، حقول زائدة (idPhoto required) |
| 4 | Pending Approval screen | ❌ toast فقط — **لا شاشة** |
| 5 | Verification (email/phone/OTP) | ❌ لا شيء |
| 6 | Forgot Password | ❌ لا شيء |
| 7 | Onboarding (interests/categories/city/causes) | ❌ لا شيء |
| 8 | Roles (Volunteer/Admin/Moderator/Partner/Campaign Leader) | ❌ `isAdmin` boolean فقط |
| 9 | Responsive | ⚠️ يحتاج تحقّق عبر المقاسات |
| 10 | RTL/LTR | ✅ `applyI18n` (نلتزم logical props بالجديد) |
| 11 | Reusable components (OTP/steps/states…) | ⚠️ أساس موجود، ناقص OTP/step-indicator/success/error موحّدة |
| 12 | Emotional UX | ⚠️ وظيفي، يحتاج تلميع |
| 13 | Audit/توحيد/إزالة تكرار | ⏳ (هذا التقرير) |
| 14 | نظام متكامل (admin/profile/onboarding/notifications/permissions) | ⚠️ approve موجود، الباقي يُربط |

---

## ج) المعمارية المقترحة (scalable)

1. **`AuthService` (جديد)** — مصدر واحد للمصادقة: `login()`, `register()`, `logout()`, `currentUser()`, `restoreSession()`, `requestReset()`, `resetPassword()`, `sendOtp()`, `verifyOtp()`. يلفّ المنطق الموجود في `doLogin/doSignup` (إزالة التكرار). تبقى `UserService` لـ CRUD.
2. **Roles & Permissions** — `CONFIG.ROLES = { volunteer, moderator, campaign_leader, partner, admin }` مع صلاحيات؛ `user.role` (افتراضي `volunteer`)؛ `Permissions.can(user, action)`. تبقى `isAdmin` مشتقّة (توافق خلفي) لكن المنطق يصير role-based. **لا hardcode للأدوار.**
3. **Verification model** — `user.verification = { email:{verified,code,sentAt}, phone:{...} }` + `OtpService` (stub جاهز للـ backend/OTP لاحقًا).
4. **Auth Screens (شاشات كاملة لا modals)** للإحساس الـ premium: Welcome · Login · Register (multi-step) · Pending Approval · Forgot Password (multi-step) · Onboarding. ضمن `#authFlow` بنظام خطوات.
5. **مكتبة مكوّنات auth (CSS+JS):** `auth-input`, `auth-btn`, `otp-input`, `field-error`, `step-indicator`, `auth-card`, `success-state`, `error-state`, `pending-state`.

---

## د) ترتيب البناء المقترح (دفعات مُتحقَّق منها + لينك بعد كلٍّ)

| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **2.0** | أساس معماري: `AuthService` + Roles/Permissions + verification model (refactor بلا تغيير UI) | منخفضة |
| **2.1** | مكتبة مكوّنات auth (CSS+JS) | منخفضة |
| **2.2** | Welcome + onboarding preview (تطوير loginScreen) | متوسطة (UI) |
| **2.3** | Login (email/phone، remember me، states) | متوسطة |
| **2.4** | Registration (multi-step + confirm password) + **Pending Approval screen** | متوسطة |
| **2.5** | Forgot Password (request → verify → reset → success) | متوسطة |
| **2.6** | Onboarding (interests/categories/city/causes) بعد الموافقة | متوسطة |
| **2.7** | Verification/OTP + تلميع عاطفي + responsive sweep | متوسطة |

> كل دفعة: HTML+CSS+JS كوحدة → `node --check` + فحص الدوال + jsdom + لينك.

**ملاحظة:** ضل بند **A (توحيد المسافات `--sp-*`)** من Phase 1 مؤجّلًا — نرجعله.
