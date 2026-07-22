# Project Inventory Report

**Source Folder:** `king_wins_app_frontend-main`
**Total Source Files:** 26 (excluding build/lock outputs)

## File Inventory Summary

| Path | Category | Purpose / Description |
| --- | --- | --- |
| `package.json` | Configuration | NPM dependencies, scripts, project metadata |
| `package-lock.json` | Lockfile | Locked dependency versions |
| `vite.config.ts` | Build Config | Vite bundler configuration (React + Tailwind plugins, port 5000) |
| `tsconfig.json` | TS Config | TypeScript root project configuration |
| `tsconfig.app.json` | TS Config | TypeScript app compilation configuration |
| `tsconfig.node.json` | TS Config | TypeScript Node compilation configuration |
| `eslint.config.js` | Linting | ESLint 9 configuration with React plugins |
| `index.html` | Entry | Single Page App HTML container |
| `vercel.json` | Deployment | Vercel deployment route rewrites |
| `.gitignore` | Git | Excluded paths and build outputs |
| `README.md` | Docs | Project overview |
| `public/sw.js` | PWA / Service Worker | Web Push notification handler |
| `public/vite.svg` | Asset | Vite brand logo |
| `src/main.tsx` | Entry | React DOM application root rendering |
| `src/App.tsx` | Root Component | Main app wrapper, session expiry listener, BrowserRouter |
| `src/App.css` | Styles | Main root style overrides |
| `src/index.css` | Styles | Tailwind CSS imports, global colors, marquee animation, scrollbar styling |
| `src/firebase.ts` | Integration | Firebase app initialization & Auth service |
| `src/vite-env.d.ts` | Types | Vite environment types |
| `src/api/axios.ts` | API Client | Axios instance, JWT Bearer token interceptor, auto refresh queue, paginated response unpacker |
| `src/api/auth.api.ts` | API Client | Authentication endpoints: login, firebaseLogin, me, logout |
| `src/api/results.api.ts` | API Client | Satta Matka endpoints: live results, history, deposit/withdraw requests, bets, game rates |
| `src/api/notifications.api.ts` | API Client | Notification endpoints: items, mark read, unread count, Web Push subscription |
| `src/assets/under_maintance.png` | Asset | Maintenance / Blocked Account illustration |
| `src/assets/react.svg` | Asset | React brand icon |
| `src/components/Sidebar.tsx` | Component | Slide-out navigation drawer with user profile & collapsible Bank/UPI details form |
| `src/hooks/useWebPush.ts` | Custom Hook | Browser Service Worker registration & VAPID Web Push subscription |
| `src/pages/Login.tsx` | Page | Login form with phone/password, error handling, blocked account UI |
| `src/pages/Register.tsx` | Page | Two-step registration: form -> Firebase SMS OTP verification -> backend registration |
| `src/pages/Home.tsx` | Page | Main dashboard: ticker banner, action grid, live markets, passbook, my-bids, funds, game rates, charts, settings, add-fund modal, withdraw modal, chart modal |
| `src/pages/PlayMarket.tsx` | Page | Betting screen for 11 game modes: Single, Jodi, Single Panna, Double Panna, Triple Panna, SP Motor, DP Motor, SP DP TP, Half Sangam, Full Sangam, Family Panel |
| `src/routes/AppRoutes.tsx` | Routing | React Router v7 routes with ProtectedRoute guard |
