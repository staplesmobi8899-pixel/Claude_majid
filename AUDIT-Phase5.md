# Phase 5 — Campaign System: Audit & Plan

> audit + خطة. لا كود قبل الاتفاق (تمّ: المالك وافق على البدء بـ 5.0).

## أ) الموجود (audit)
- **`CampaignService`:** getAll/getById/getVisible/add/updateById · approve/reject/markUnderProcess/**markDone** (يمنح ساعات+إنجازات للمنضمّين) · **join** (تحقّق كامل: مستخدم مفعّل، غير ممتلئة، غير منضمّ، حالة صحيحة؛ يزيد volunteers/joinedUsers؛ تحوّل under_process عند الامتلاء).
- **`Models.createCampaign`:** ar/en + category(key) + location/date/needed/volunteers/volunteerHours + status(pending أو approved للأدمن) + createdBy + creatorName/Phone + img + joinedUsers/campHours.
- **التفاصيل (`detailPage`):** هيرو صورة + فئة/عنوان/وصف + شبكة (تاريخ/موقع/متطوعون/منظّم) + تقدّم + هاتف + زر انضمام.
- **الإنشاء (`createPage`+`createModal`):** hero + زر يفتح modal + قائمة «حملاتي».
- **الحالات:** pending · approved · under_process · done · rejected.
- **الفئات (Phase 4):** 8 (environment/education/health/community/youth/sustainability/food_aid/animal_care) + aliases.

## ب) الفجوات مقابل البريف
| # | المطلوب | الحالة |
|---|---|---|
| 1 | تفاصيل سينمائية (قصة · متطلبات · وقت/مدة · إحصاءات أثر · gallery) | ⚠️ أساسية |
| 2 | Join flow (request → approval → confirmation → attendance → completion) | ⚠️ انضمام فوري فقط |
| 3 | إنشاء premium guided (multi-step · media · أهداف) | ⚠️ modal بسيط |
| 4 | حالات: + **archived** | ⚠️ ناقص archived |
| 5 | فئات: + **Public Spaces · Emergency Response** (10) | ⚠️ 8 |
| 6 | تتبّع تطوّع (attendance · history · completion) موصول بالبروفايل/الأنالتكس/الإنجازات/leaderboard/الأدمن | ⚠️ ساعات+إنجازات فقط |
| 7 | تقدّم (% · هدف · milestones · impact) | ⚠️ شريط تقدّم فقط |
| 8 | Media (gallery · video-ready) | ⚠️ صورة واحدة |
| 9 | Location (map-ready · nearby) | ⚠️ نص مدينة |
| 10 | Campaign dashboard للمنشئ (مشاركون · تقارير) | ❌ |
| 11 | تكامل الإشعارات (موافقات · تحديثات · alerts) | ⚠️ جزئي |
| 14 | مكوّنات (card · chip · progress · gallery · counters · attendance · join · badges) | ⚠️ بعضها |

## ج) ترتيب البناء (دفعات مُتحقَّق منها + لينك)
| دفعة | المحتوى | مخاطرة |
|---|---|---|
| **5.0** | أساس: فئات 10 + حالة `archived` + نموذج **participants** + **bookmarks (حفظ)** + **leave** + `Permissions.canManageCampaign` + accessor مشاركين + hooks إشعارات (موافقة/رفض/انضمام للمنشئ). refactor، تغيير UI طفيف | منخفضة |
| **5.1** | تفاصيل الحملة السينمائية: قصة · متطلبات · مدة · إحصاءات · gallery · حفظ/مشاركة · مشاركون · تحكّم المنشئ · مغادرة | متوسطة |
| **5.2** | إنشاء كشاشة كاملة multi-step + media + معاينة | متوسطة |
| **5.3** | إدارة «حملاتي» (مشاركون/حضور/إنهاء/أرشفة) + Saved campaigns + تكامل الأنالتكس/الإنجازات | متوسطة |

> كل دفعة: HTML+CSS+JS كوحدة → node --check + jsdom + لينك. كل شي موصول (بروفايل/أدمن/إشعارات/إنجازات).
