# API Integration Status

| Endpoint | Method | Mobile Service Class | Integration Status | Fallback / Mock Behavior |
| --- | --- | --- | --- | --- |
| `/auth/login/` | `POST` | `AuthService.login` | Verified | Throws `AccountBlockedException` when `ACCOUNT_BLOCKED` returned |
| `/auth/firebase-login/` | `POST` | `AuthService.firebaseLogin` | Verified | Accepts Firebase SMS `idToken` |
| `/auth/me/` | `GET`/`PATCH` | `AuthService.getProfile` | Verified | Cached locally in `SharedPreferences` |
| `/results/live/` | `GET` | `ResultsService.getLiveResults` | Verified | Filters WhatsApp entries & locked 11:59 PM markets |
| `/results/history/` | `GET` | `ResultsService.getSattaHistory` | Verified | Generates weekly Jodi & Panel grids |
| `/deposit-requests/` | `POST`/`GET` | `ResultsService.createDepositRequest` | Verified | User redirected to admin WhatsApp |
| `/withdraw-requests/` | `POST`/`GET` | `ResultsService.createWithdrawRequest` | Verified | Validates IFSC, Bank, and UPI details before sending |
| `/bets/` | `POST`/`GET` | `ResultsService.placeBid` | Verified | Local mirror in `my_bids` for offline access |
| `/game-rates/` | `GET` | `ResultsService.getGameRates` | Verified | Fallback to default Satta Matka multipliers |
