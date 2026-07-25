# Wallet API Contract

## Overview
This document specifies the discovered backend API contract for fetching and managing user wallet balance in the King Wins application.

## API Discovered Contract Matrix

| Property | Discovered Value | Evidence |
|----------|------------------|----------|
| Base URL | `https://api.quebix.in/api/v1` | Discovered in `lib/features/auth/data/services/auth_api_service.dart` & build config |
| Endpoint | `/auth/me/` | Discovered in `AuthApiService.getProfile()` |
| Method | `GET` | Discovered in `_dio.get('/auth/me/')` |
| Auth header | `Authorization: Bearer <access_token>` | Discovered in `lib/core/network/api_client.dart` token interceptor |
| Balance field | `wallet_balance` (fallbacks: `points`, `balance`) | Discovered in `UserModel.fromJson()` (`json['wallet_balance'] ?? json['points'] ?? json['balance']`) |
| Currency / Unit | Indian Rupees (`₹` / integer points) | Discovered in UI design (`₹` prefix) and domain comments ("Stored in integer rupees") |
| Success code | `200 OK` | Standard HTTP 200 payload containing user data object |
| Error format | `{"detail": "..."}` or `{"error": "..."}` | Discovered in `AuthApiService._handleDioError` |
| Refresh behavior | On-demand GET request upon login, screen open, pull-to-refresh, or post-transaction | Triggered via `WalletViewModel.fetchBalance()` |

## Response Payload Example
```json
{
  "id": 1,
  "phone_number": "9876543210",
  "name": "Test User",
  "wallet_balance": 58850,
  "is_blocked": false
}
```
