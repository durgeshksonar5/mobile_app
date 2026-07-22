# API Endpoint Matrix

| Feature | Method | Endpoint Path | Auth Required | Request Model | Response Model | Error Handling | Web Source File | Flutter Service | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Login | `POST` | `/auth/login/` | No | `{ phone_number: string, password: string }` | `{ access: string, refresh: string, user: User }` | `401 Invalid`, `400 ACCOUNT_BLOCKED` | `src/api/auth.api.ts` | `AuthService.login` | Implemented |
| Firebase Auth / OTP | `POST` | `/auth/firebase-login/` | No | `{ id_token: string, name?: string, password?: string, is_register?: boolean }` | `{ access: string, refresh: string, user: User }` | `400 Bad Request` | `src/api/auth.api.ts` | `AuthService.firebaseLogin` | Implemented |
| Get User Profile | `GET` | `/auth/me/` | Yes | None | `{ success: boolean, data: User }` | `401 Unauthorized` | `src/api/auth.api.ts` | `AuthService.getProfile` | Implemented |
| Update Profile / Bank | `PATCH` | `/auth/me/` | Yes | `{ name?, bank_name?, account_number?, ifsc_code?, upi_id?, upi_number? }` | `{ success: boolean, data: User }` | `400 Bad Request` | `src/api/auth.api.ts` | `AuthService.updateProfile` | Implemented |
| Logout | `POST` | `/auth/logout/` | Yes | `{ refresh: string }` | `{ success: boolean }` | Silent fallback | `src/api/auth.api.ts` | `AuthService.logout` | Implemented |
| Live Results | `GET` | `/results/live/` | Yes | None | `MarketResult[]` (auto unpacked) | Network retry (max 2) | `src/api/results.api.ts` | `ResultsService.getLiveResults` | Implemented |
| Satta History | `GET` | `/results/history/` | Yes | `?market_name=...&page_size=100` | `MarketResult[]` | Fallback empty list | `src/api/results.api.ts` | `ResultsService.getSattaHistory` | Implemented |
| Deposit Request | `POST` | `/deposit-requests/` | Yes | `{ amount: number }` | `{ id: number, amount: number, status: string, created_at: string }` | `400 Bad Request` | `src/api/results.api.ts` | `ResultsService.createDepositRequest` | Implemented |
| Withdraw Request | `POST` | `/withdraw-requests/` | Yes | `{ amount: number }` | `{ id: number, amount: number, status: string, created_at: string }` | `400 Insufficient funds / No bank details` | `src/api/results.api.ts` | `ResultsService.createWithdrawRequest` | Implemented |
| Get Deposit Requests | `GET` | `/deposit-requests/` | Yes | None | `DepositRequest[]` | Empty array | `src/api/results.api.ts` | `ResultsService.getDepositRequests` | Implemented |
| Get Withdraw Requests | `GET` | `/withdraw-requests/` | Yes | None | `WithdrawRequest[]` | Empty array | `src/api/results.api.ts` | `ResultsService.getWithdrawRequests` | Implemented |
| Place Bid (Bet) | `POST` | `/bets/` | Yes | `{ market_name: string, game_type: string, session: string, selected_number: string, amount: number }` | `{ id: number, ... }` | `400 Market Closed / Insufficient Balance` | `src/api/results.api.ts` | `ResultsService.placeBid` | Implemented |
| Get Bids | `GET` | `/bets/` | Yes | None | `BidItem[]` | Fallback `localStorage` | `src/api/results.api.ts` | `ResultsService.getBids` | Implemented |
| Game Rates | `GET` | `/game-rates/` | Yes | None | `GameRate[]` | Fallback static rates | `src/api/results.api.ts` | `ResultsService.getGameRates` | Implemented |
| Token Refresh | `POST` | `/auth/token/refresh/` | No | `{ refresh: string }` | `{ access: string, refresh?: string }` | `401 Expiry event` | `src/api/axios.ts` | `AuthInterceptor.refreshToken` | Implemented |
