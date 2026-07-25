# Wallet Functionality Audit

## Overview
This document audits the wallet balance functionality, source files, data flow, current problems, and required fixes within the King Wins Flutter application.

## Audit Matrix

| Item | Current Implementation | Source File | Problem | Required Fix |
|------|------------------------|-------------|---------|--------------|
| Wallet Balance Display | Hard-coded or stale `user?.walletBalance ?? 0` read from `AuthState` | `lib/features/home/presentation/screens/home_screen.dart` | Balance does not update after placing bets, deposits, or withdrawals because there is no dedicated wallet state or refresh trigger | Bind wallet chip to dedicated `walletViewModelProvider` with real-time refresh capability |
| Wallet API Endpoint | User profile endpoint `/auth/me/` returns `wallet_balance` / `points` / `balance` | `lib/features/auth/data/services/auth_api_service.dart` | No dedicated `WalletApiService` or `WalletRepository` for wallet operations | Create `WalletApiService` & `WalletRepository` wrapping `/auth/me/` balance fetching |
| Wallet Data Model | Parsed into `UserModel.walletBalance` as `int` | `lib/features/auth/domain/models/user_model.dart` | No dedicated `WalletBalance` entity with explicit status, currency, and minor/major unit handling | Create `WalletBalance` domain entity with safe num/string/null parser and integer rupee unit |
| Wallet State Management | Monolithic `AuthState` without loading, error, or refreshing states for wallet | `lib/features/auth/presentation/states/auth_state.dart` | UI shows static 0 during load or error; no pull-to-refresh or event-driven balance invalidation | Create `WalletState` & `WalletViewModel` with explicit states (`initial`, `loading`, `loaded`, `error`, `refreshing`) |
| Post-Transaction Refresh | No automatic refresh after bid placement or deposit/withdraw request | `lib/features/play_market/presentation/view_models/play_market_view_model.dart` | Balance remains stale after user places a bet | Call `walletViewModelProvider.notifier.refreshBalance()` after successful bid placement or deposit/withdraw |
| Logout Clearing | Auth state cleared on logout | `lib/features/auth/presentation/view_models/auth_view_model.dart` | Wallet provider state could retain previous user's balance if cached separately | Ensure `WalletViewModel.reset()` clears cached balance on logout |
