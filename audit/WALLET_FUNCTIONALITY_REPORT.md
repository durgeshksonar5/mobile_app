# Wallet Functionality Report

## Overview
This document summarizes the wallet balance implementation, data model, state management, refresh behavior, security, and verification results for the King Wins application.

## Discovered Backend API Contract
- **Endpoint**: `/auth/me/`
- **Request Method**: `GET`
- **Authentication**: `Authorization: Bearer <access_token>`
- **Response Balance Field**: `wallet_balance` (with fallbacks to `points` and `balance`)
- **Currency / Unit**: Indian Rupees (`₹` / integer points)
- **Base URL**: `https://api.quebix.in/api/v1`

## Files Created & Changed

| File Path | Description | Reason |
|-----------|-------------|--------|
| `audit/WALLET_FUNCTIONALITY_AUDIT.md` | Initial audit document | Itemized audit matrix of wallet problems and required fixes |
| `audit/WALLET_API_CONTRACT.md` | API contract specification | Formal backend API specification discovered from source |
| `audit/WALLET_FUNCTIONALITY_REPORT.md` | Final completion report | Comprehensive summary report of wallet implementation |
| `lib/features/wallet/domain/models/wallet_balance.dart` | Typed domain model | Safely parses int, num, decimal string, nulls without double float imprecision |
| `lib/features/wallet/data/services/wallet_api_service.dart` | Wallet API Service | Executes HTTP GET `/auth/me/` request with Dio & error mapping |
| `lib/features/wallet/domain/repositories/wallet_repository.dart` | Wallet Repository interface | Defines contract for fetching balance and clearing cache |
| `lib/features/wallet/data/repositories/wallet_repository_impl.dart` | Wallet Repository implementation | Handles API fetching, in-memory caching, and local storage fallback |
| `lib/features/wallet/presentation/states/wallet_state.dart` | Wallet State object | Explicit states: `initial`, `loading`, `loaded`, `refreshing`, `error` |
| `lib/features/wallet/presentation/view_models/wallet_view_model.dart` | Wallet StateNotifier | Riverpod ViewModel managing async balance fetching, throttling, and state updates |
| `lib/app/dependency_injection/providers.dart` | Dependency Injection | Registered `walletApiServiceProvider` & `walletRepositoryProvider` |
| `lib/features/home/presentation/screens/home_screen.dart` | Home Screen UI | Bound AppBar wallet chip to `walletViewModelProvider` while strictly preserving chip layout & styling |
| `lib/features/home/presentation/widgets/add_fund_dialog.dart` | Add Fund Dialog | Triggered wallet balance refresh after successful deposit submission |
| `lib/features/home/presentation/widgets/withdraw_dialog.dart` | Withdraw Dialog | Triggered wallet balance refresh after successful withdrawal request |
| `lib/features/play_market/presentation/view_models/play_market_view_model.dart` | Play Market ViewModel | Triggered wallet balance refresh after successful bid placement |
| `test/unit/wallet_balance_test.dart` | Unit tests | Tests model parsing, edge cases, state transitions, and state clearing |
| `test/widget/home_screen_test.dart` | Widget tests | Verified dynamic wallet balance rendering in AppBar chip |

## Wallet States & Behavior
1. **Initial**: Default state before authentication; balance displays `0`.
2. **Loading**: Small progress loader shown within existing chip dimensions when initial balance is fetching.
3. **Loaded**: Dynamic integer balance rendered inside AppBar chip.
4. **Refreshing**: Keeps previous balance visible while silently refreshing balance in background.
5. **Error**: Retains last valid balance or controlled fallback; allows retry via refresh button without crashing or corrupting UI layout.

## Refresh Triggers
- Automatic fetch upon user login & home screen load.
- Manual pull-to-refresh & AppBar refresh button tap.
- Automatic background refresh after submitting deposit request (`AddFundDialog`).
- Automatic background refresh after submitting withdrawal request (`WithdrawDialog`).
- Automatic background refresh after placing bets (`PlayMarketViewModel`).
- Automatic refresh when app resumes from background.
- Full state and cache reset on user logout (`WalletViewModel.reset()`).

## Verification Results
- `flutter pub get`: Passed
- `dart format .`: Passed (formatted 18 files)
- `flutter analyze --fatal-infos --fatal-warnings`: Passed with **0 issues**
- `flutter test`: Passed all **52 unit & widget tests**
- Release APK build: Successfully built `build\app\outputs\flutter-apk\app-release.apk` (26.3 MB) with production flags:
  - `APP_ENV=production`
  - `API_BASE_URL=https://api.quebix.in/api/v1`
  - `WHATSAPP_LINK=https://wa.link/ctw7uq`
