# Light Gold Color Usage Audit

This report documents the light black-and-gold theme color mappings and the migration of hardcoded colors to semantic design tokens.

## Design Token Definitions

The new color palette defined in `lib/app/theme/app_colors.dart` establishes clean contrast and consistent visual aesthetics:

| Category | Token Name | Hex Value | Intent / Description |
| :--- | :--- | :--- | :--- |
| **Brand Highlight** | `goldHighlight` | `#F8D044` | High-contrast gold accents |
| **Brand Primary** | `mainGold` | `#E4AA25` | Primary buttons and key branding elements |
| **Brand Accent** | `midGold` | `#C58514` | Button active overlay/press states |
| **Brand Shadow/Accent** | `darkGold` | `#A06009` | Active inputs, focused states, and selected navigation |
| **Warm Accent** | `bronze` | `#773F06` | Secondary active elements |
| **Deep Accent** | `deepBronze` | `#422106` | Component shadows and deep background accents |
| **Light Accent** | `lightGold` | `#F4E57C` | Gradient highlights and warm cards |
| **Soft Accent** | `softGold` | `#FBF7CB` | Selected list items and active backgrounds |
| **Surfaces** | `background` | `#FFF9E8` | Main application background (Warm Ivory) |
| **Surfaces** | `surface` | `#FFFFFF` | Primary card background |
| **Surfaces** | `surfaceGold` | `#FFF4D6` | Highlighted surfaces and user profile header |
| **Text** | `textPrimary` | `#1A1408` | Primary body text (Deep Charcoal/Bronze) |
| **Text** | `textSecondary` | `#5A4421` | Secondary descriptions |
| **Text** | `textMuted` | `#7A6A4B` | Hints and muted icons |
| **Borders** | `border` | `#E7D5A2` | Standard card and text field borders |
| **Borders** | `divider` | `#EDE2C6` | Dividers and thin separating lines |
| **Disabled** | `disabledBackground`| `#E7DFC9` | Background of disabled buttons/inputs |
| **Disabled** | `disabledForeground`| `#978B70` | Text/icon color of disabled elements |

---

## Migrated Hardcoded Colors and Contrast Adjustments

All raw hexadecimal values found in layouts were replaced with unified semantic tokens or contrast-safe approved colors:

1. **Login & Register Headers**:
   - *Before*: White text on low-contrast gold gradients.
   - *After*: Swapped banner gradients to the approved light gold gradient `[#F8D044, #E4AA25, #C58514]` and updated all title, subtitle, and back-button elements to `AppColors.textPrimary` (`#1A1408`).

2. **AppBar & Global Shell**:
   - *Before*: Solid colored AppBars with white actions.
   - *After*: Configured the global `AppBarTheme` to use `AppColors.surface` background with `AppColors.textPrimary` title text. Configured AppBar icons to automatically default to `AppColors.textPrimary` and action icons to `AppColors.darkGold`.
   - Updated the Wallet Balance pill container in `home_screen.dart` to use `AppColors.surfaceGold` background, `AppColors.border`, and `AppColors.textPrimary` text.

3. **Sidebar Drawer**:
   - *Before*: Grey user header (`#F9FAFB`) with blue details/avatar.
   - *After*: Updated profile container to `AppColors.surfaceGold` with `AppColors.softGold` avatar, `AppColors.border` border, and `AppColors.darkGold` person icon.
   - Updated selected list items to use `AppColors.softGold` background and `AppColors.darkGold` label/icon.

4. **Digit Bids & Modal Dialogs**:
   - *Before*: Selected numbers and digits had white text (`AppColors.textWhite`) on a light gold background.
   - *After*: Updated text colors to `AppColors.textPrimary` (`#1A1408`) for high contrast on active gold items.
