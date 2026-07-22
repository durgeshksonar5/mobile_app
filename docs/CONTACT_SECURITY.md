# Contact Data Security & Sanitization Specification

## Security & Logging Rules

1. **HTTPS Transit Only:** All contact payloads are transmitted strictly over TLS 1.3/HTTPS using Bearer JWT authentication.
2. **Sanitized Logs:** Console and file logs record **only** aggregate metrics (e.g. `synced_count: 3`, `batch_id: batch_1001`). Raw names, phone numbers, and email addresses are **never** written to logcat, stdout, analytics, or crash reports.
3. **No Query String Exposure:** Sensitive contact data is never passed in URL query parameters.
4. **Isolated Memory Lifecycle:** In-memory contact arrays are garbage collected immediately upon upload completion.
