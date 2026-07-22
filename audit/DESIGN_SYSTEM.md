# King Win Design System Audit

**Extracted from:** `src/index.css`, `src/App.css`, `src/pages/Home.tsx`, `src/pages/Login.tsx`, `src/pages/Register.tsx`, `src/pages/PlayMarket.tsx`, `src/components/Sidebar.tsx`

---

## 1. Color Palette Tokens

| Token Name | Hex / Value | Description / Usage |
| --- | --- | --- |
| `primaryGold` | `#D3A745` | Main brand color (Header, Primary Buttons, Active Tabs, Highlights) |
| `primaryGoldLight` | `#E3C67C` | Gradient end color, soft hover state |
| `primaryGoldDark` | `#B4964B` | Gradient start hover, active button press state |
| `primaryGoldBg` | `rgba(211, 167, 69, 0.1)` | Subtle chip backgrounds, icon containers |
| `backgroundLight` | `#F3F4F6` | Main app page background |
| `surfaceWhite` | `#FFFFFF` | Card surfaces, dialog backgrounds, bottom navigation bar |
| `surfaceDark` | `#111827` / `#030712` | Dark mode / Blocked account background (`gray-950`, `gray-900`) |
| `textPrimary` | `#1F2937` | Main heading and body text (`gray-800` / `gray-900`) |
| `textSecondary` | `#6B7280` | Subtitle and muted text (`gray-500` / `gray-400`) |
| `statusGreen` | `#16A34A` | Running Market, Approved Status, Win Badge |
| `statusRed` | `#BA1F1F` | Market Closed, Rejected Status, Loss Badge |
| `statusAmber` | `#F59E0B` | Running Close Session, Pending Status |
| `borderLight` | `#E5E7EB` | Soft divider borders (`gray-150` / `gray-200`) |

---

## 2. Typography

| Role | Font Family | Size | Weight | Line Height |
| --- | --- | --- | --- | --- |
| **Header Title** | `Inter`, system-ui | 24px (1.5rem) | 800 (Extrabold) | 1.2 |
| **Card Title** | `Inter`, system-ui | 17px | 800 (Extrabold) | 1.3 |
| **Body Large** | `Inter`, system-ui | 15px | 600 (Semibold) | 1.4 |
| **Body Regular** | `Inter`, system-ui | 14px | 500 (Medium) | 1.5 |
| **Caption / Meta** | `Inter`, system-ui | 12px | 500 (Medium) | 1.4 |
| **Badge / Label** | `Inter`, system-ui | 10px - 11px | 700 (Bold) | 1.2 |

---

## 3. Spacing & Radius Scale

- **Card Radius:** 16px to 24px (`rounded-2xl`, `rounded-3xl`)
- **Button Radius:** 12px to 16px (`rounded-xl`, `rounded-2xl`)
- **Input Padding:** 12px vertical, 16px horizontal
- **Screen Margin:** 16px (`px-4 py-4`)
- **Grid Gap:** 10px (`gap-2.5`) to 16px (`gap-4`)

---

## 4. Key Motion & Micro-animations

- **Ticker Marquee:** 25s linear infinite CSS scroll (`@keyframes marquee`)
- **Spinner Loader:** 360deg rotation (`animate-spin`)
- **Touch Feedback:** `active:scale-[0.99]` or `active:scale-95` tap feedback scale
