# ATHAR — Brand Identity Analysis (v2.0 Refined)

> مرجع دقيق مستخرَج من لوحة الهوية البصرية الرسمية. يُستخدم لمحاذاة نظام التصميم (design tokens) مع الهوية عبر المراحل.

## 1) Color Palette — "Earthy. Organic. Timeless."

| Name | Hex | Role | Current token | Status |
|---|---|---|---|---|
| Deep Forest | `#2E3D1F` | Primary dark · backgrounds · headlines | dark bg `#121810` | ❌ gap (current too black) |
| Olive | `#5C6A3A` | Primary | `--olive #5a6b3a` | ✅ ~match |
| Sage | `#8A9B6E` | Secondary · subtle | `--olive-light #8a9a6a` | ✅ ~match |
| Stone | `#C4B89A` | Cards · backgrounds | — | ⚠️ missing |
| Warm Beige | `#E8E0D0` | Cards · backgrounds | `--sand-dark #e8d9c4` | ≈ close |
| Off White | `#F5F2EC` | Page bases · clean space | `--sand #f5ede1` / `--warm-white #fdfaf6` | ≈ close |

**Accessible pairings:** Forest+Olive / Off White · Olive / Off White · Sage / Off White · Off White / Forest.
**Usage distribution:** ~50% Forest+Olive · ~30% Off White · ~20% Sage+Olive.

### Proposed brand-aligned token additions
```
--forest:      #2E3D1F;   /* replaces near-black dark surfaces */
--olive:       #5C6A3A;   /* nudge from #5a6b3a */
--sage:        #8A9B6E;   /* = current --olive-light, nudge */
--stone:       #C4B89A;   /* NEW mid tan */
--warm-beige:  #E8E0D0;
--off-white:   #F5F2EC;
```

## 2) Typography — "Two languages. One voice."

| Use | Brand font | Size / tracking | Current |
|---|---|---|---|
| Arabic display/heading | **Noto Naskh Arabic** Bold | 56–60px | Tajawal ❌ |
| Arabic body | **Noto Naskh Arabic** Regular | 15–17px · 1.8 line | Tajawal ❌ |
| English display | **DM Serif Display** Regular | 56–60px · −2.5% | Inter ❌ |
| English heading | **DM Sans** | 24–32px · −0.5% | Inter ❌ |
| English body/UI | **DM Sans** Regular | 15–17px · 1.7 line | Inter ❌ |

> Identity = elegant serif for English headlines + traditional Naskh for Arabic (editorial, Patagonia/Notion feel). Differs fundamentally from current Tajawal/Inter.

## 3) Logo / Mark
- **Mark:** fingerprint + two-leaf sprout. "The secret": one outer ridge extends past the fingerprint and becomes a tiny two-leaf sprout — look once you see a fingerprint, look again you discover life growing from it.
- Wordmark: أثر + ATHAR. App icon: fingerprint on Deep Forest rounded square.
- **Current app:** text-only «أَثَرْ» — mark is missing.

## 4) Voice / Tagline
- AR: «لمسة تترك أثرًا» · EN: "Every touch leaves a legacy." / "Every human touch leaves a positive impact." / "Small actions. Big impact."
- Meaning of أثر: impact, trace, legacy (Arabic).
- **Current app tagline:** «أثر يبدأ بخطوة» — should align to brand copy.

## 5) Patterns & Motion
- **Patterns:** 01 Ridges (concentric fingerprint), 02 Grid (dots), 03 Stripe (vertical lines). → current hero already uses rings + grid (on-brand ✅).
- **Motion:** Upward Growth (ease-out, grows upward — core plant metaphor) · Gentle Curves (`cubic-bezier(0.22, …)`, ~600ms, never mechanical) · Stagger (children appear with delay → rhythm + hierarchy). → Phase 11.

## 6) Components (Design System)
- Buttons: pill primary (Forest/Olive), outline secondary; sizes Small / Default / Large.
- Badges: VOLUNTEER · ACTIVE · COMMUNITY (green) · ARCHIVED · LIVE NOW (beige).
- Cards: profile card (avatar + name + role · city), campaign card, impact dashboard (large impact score e.g. "342").
- App sections: Campaigns · Volunteers · Impact · Community · Profile.

## Summary of gaps to resolve (pending agreement)
1. **Dark surfaces** `#121810` → **Deep Forest `#2E3D1F`** (highest visual impact).
2. Add **Stone `#C4B89A`** token; nudge olive/sage to exact brand hex; add forest/beige/off-white tokens.
3. **Fonts:** adopt Noto Naskh Arabic + DM Serif Display + DM Sans (vs Tajawal/Inter) — identity-defining decision.
4. **Logo mark:** add fingerprint + two-leaf sprout SVG.
5. **Tagline/voice:** align copy to brand.
