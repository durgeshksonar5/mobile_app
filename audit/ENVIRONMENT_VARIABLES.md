# Environment Variables Audit

**Source Folder:** `king_wins_app_frontend-main`

| Variable Name | Default / Fallback | Reference File | Description |
| --- | --- | --- | --- |
| `VITE_API_URL` | `http://localhost:8000/api/v1` | `src/api/axios.ts` | Base API URL for Django REST API |
| `VITE_apiKey` | Environment provided | `src/firebase.ts` | Firebase Web API Key |
| `VITE_authDomain` | Environment provided | `src/firebase.ts` | Firebase Auth Domain |
| `VITE_projectId` | Environment provided | `src/firebase.ts` | Firebase Project ID |
| `VITE_storageBucket` | Environment provided | `src/firebase.ts` | Firebase Storage Bucket |
| `VITE_messagingSenderId` | Environment provided | `src/firebase.ts` | Firebase Messaging Sender ID |
| `VITE_appId` | Environment provided | `src/firebase.ts` | Firebase Web App ID |
| `VITE_measurementId` | Environment provided | `src/firebase.ts` | Firebase Analytics Measurement ID |

> [!NOTE]
> No hard-coded API secrets or private keys were found in the frontend source code. All Firebase credentials use standard client-side identifiers for Web SMS Auth.
