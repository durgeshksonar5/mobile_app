# Web to Flutter Technology and Component Mapping

| Web Concept / Library | Source Reference | Flutter Equivalent | Implementation Details |
| --- | --- | --- | --- |
| **React 19 / JSX** | `src/App.tsx`, `src/pages/*.tsx` | Native Flutter Widgets (`StatelessWidget`, `StatefulWidget`) | Pure native Dart implementation with zero WebViews |
| **React Router v7** | `src/routes/AppRoutes.tsx` | `go_router: ^14.8.1` | Declarative routing with path parameters & route guards |
| **Axios HTTP Client** | `src/api/axios.ts` | `dio: ^5.8.0+1` | Custom Interceptors for JWT Bearer token & automatic token refresh queue |
| **localStorage** | `localStorage.getItem()` | `flutter_secure_storage` + `shared_preferences` | Tokens stored in encrypted Secure Storage, non-sensitive state in SharedPreferences |
| **TailwindCSS Classes** | `@import "tailwindcss";`, Utility classes | Centralized `AppTheme`, `AppColors`, `AppTypography` | Custom design tokens matching `#D3A745` Gold theme |
| **Lucide Icons** | `import { Menu, Wallet } from 'lucide-react'` | `lucide_icons: ^0.257.0` | Native Flutter Lucide Icon package |
| **Service Worker / Push** | `public/sw.js`, `useWebPush.ts` | `connectivity_plus` / Push notification abstractions | Native mobile notification service layer |
| **Marquee Animation** | `@keyframes marquee` | Custom `SingleChildScrollView` / `AnimationController` Marquee Widget | Smooth infinite scrolling banner ticker |
| **Modals & Drawers** | Fixed position overlays | `showDialog`, `showModalBottomSheet`, `Scaffold.drawer` | Native Flutter modal dialogs and slide drawer |
