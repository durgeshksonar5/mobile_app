# Dependency Inventory Report

## Web Dependencies (`package.json`)

| Package Name | Version Spec | Type | Usage / Purpose |
| --- | --- | --- | --- |
| `react` | `^19.0.0` | Production | Core UI Framework |
| `react-dom` | `^19.0.0` | Production | DOM Renderer for React |
| `react-router-dom` | `^7.18.1` | Production | Routing and Navigation |
| `axios` | `^1.18.1` | Production | HTTP Client for API Requests |
| `firebase` | `^12.15.0` | Production | Firebase Authentication (Phone SMS OTP) |
| `lucide-react` | `^1.22.0` | Production | Vector Icons |
| `tailwindcss` | `^4.3.2` | Production | CSS Utility Styling |
| `@tailwindcss/vite` | `^4.3.2` | Production | Vite Plugin for TailwindCSS v4 |
| `vite` | `^6.2.0` | Dev | Frontend Bundler and Dev Server |
| `typescript` | `~5.7.2` | Dev | Static Type Checking |
| `@vitejs/plugin-react` | `^4.3.4` | Dev | Vite React Plugin |
| `eslint` | `^9.21.0` | Dev | Linter |

---

# Environment Variables (`ENVIRONMENT_VARIABLES.md`)

| Variable Name | Default / Example Value | Source File | Purpose / Usage |
| --- | --- | --- | --- |
| `VITE_API_URL` | `http://localhost:8000/api/v1` | `src/api/axios.ts` | Backend REST API Base URL |
| `VITE_apiKey` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase API Key |
| `VITE_authDomain` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase Auth Domain |
| `VITE_projectId` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase Project ID |
| `VITE_storageBucket` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase Storage Bucket |
| `VITE_messagingSenderId` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase Messaging Sender ID |
| `VITE_appId` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase App ID |
| `VITE_measurementId` | `[BUNDLE_ENV]` | `src/firebase.ts` | Firebase Analytics ID |
