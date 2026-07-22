# Contact Data Retention Policy

1. **Storage Limits:** Synced contact records are stored strictly per authenticated account ID on `api.quebix.in`.
2. **Account Deactivation Retention:** If an account is deactivated or blocked, associated contact mapping records are purged within 30 days.
3. **No Local Address Book Mirror:** The full device address book is **never** saved into local `SharedPreferences` or persistent disk caches on the client device.
