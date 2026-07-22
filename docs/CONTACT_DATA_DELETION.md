# Synced Contact Data Erasure Protocol

## User Deletion Rights

Users have the right to request deletion of all server-side synced contact records at any time directly within the application:

1. **In-App Navigation:** Go to **Settings & Profile** -> **Contacts & Privacy Settings**.
2. **Action Button:** Tap **Delete Synced Contacts**.
3. **Execution:** The app calls `DELETE /contacts/sync/delete/` over authenticated HTTPS.
4. **Consent Status Update:** Local consent status is updated to `revoked`.
5. **Confirmation:** In-app status displays `Synced Data Deleted`.
