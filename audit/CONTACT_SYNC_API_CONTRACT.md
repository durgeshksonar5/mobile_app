# Contact Sync API Discovery Contract Report

| Item | Discovered Value | Source Evidence | Flutter Implementation |
|---|---|---|---|
| **Endpoint** | **NOT FOUND** | Web frontend source code audit (`king_wins_app_frontend-main`) | Marked as BLOCKED in Production |
| **Method** | N/A | No endpoint in Axios API modules | `ContactSyncApiService` interface |
| **Auth header** | `Authorization: Bearer <access_token>` | Web standard interceptor | Handled via `AuthInterceptor` |
| **Request root field** | `contacts` | Expected JSON array payload | `ContactSyncRequestDto.contacts` |
| **Name field** | `name` | Cleaned Unicode display name | `ContactSyncItemDto.name` |
| **Phone field** | `phone` | E.164 normalized phone number | `ContactPhoneDto.phone` |
| **Email field** | Excluded | Minimum field scope requirement | Excluded unless explicitly enabled |
| **Batch limit** | 100 contacts per request batch | Conservative default | `ContactSyncRepositoryImpl.batchSize` |
| **Delete endpoint** | `/contacts/sync/delete/` | Privacy Policy Right to Erasure contract | `ContactSyncRepository.deleteSyncedContacts` |
| **Response model** | `{ success: true, count: N }` | Expected DRF envelope | `ContactSyncResponseDto` |
| **Error model** | `{ detail: "...", code: "..." }` | DRF Exception response | `ContactSyncResult` |
