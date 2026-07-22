# Web Stack Report

**Source Folder:** `king_wins_app_frontend-main`

## Stack Architecture

| Layer | Web Technology | Source Citation |
| --- | --- | --- |
| **Framework** | React 19.0.0 | `package.json` L17 |
| **Language** | TypeScript 5.7.2 | `package.json` L31 |
| **Build Tool** | Vite 6.2.0 | `vite.config.ts`, `package.json` L33 |
| **Routing** | React Router DOM v7.18.1 | `src/routes/AppRoutes.tsx` |
| **HTTP Client** | Axios 1.18.1 | `src/api/axios.ts` |
| **Authentication** | Custom Bearer JWT + Firebase Phone Auth | `src/api/auth.api.ts`, `src/firebase.ts` |
| **Styling** | TailwindCSS v4.3.2 | `src/index.css`, `vite.config.ts` |
| **Icons** | Lucide React 1.22.0 | `src/pages/Home.tsx`, `src/pages/Login.tsx` |
| **Local Storage** | Browser `localStorage` | Token management in `src/api/axios.ts` |
| **Push Notifications** | Web Push API / Service Worker | `public/sw.js`, `src/hooks/useWebPush.ts` |
| **Realtime** | REST Polling / Auto Refresh | `src/pages/Home.tsx` |

## Key Findings

1. **Routing**: Uses `BrowserRouter` with `ProtectedRoute` wrapper guarding `/` (Home) and `/play/:marketName` (PlayMarket).
2. **Auth Storage**: Stores `access_token`, `refresh_token`, and `auth_user` JSON string in `localStorage`.
3. **Session Expiry**: Dispatches custom window event `auth_session_expired` when 401 response and token refresh both fail, redirecting to `/login?expired=true`.
4. **Data Normalization**: Axios response interceptor automatically flattens Django REST Framework paginated `{ results: [...] }` envelopes or `{ success: true, data: [...] }` data objects into plain JS arrays.
5. **Mobile First UI**: Designed specifically for mobile resolution (`max-w-md mx-auto` container with fixed bottom navigation bar).
