# Contact Data Purpose Specification

## Approved Purpose Statement

`CONTACT_SYNC_PURPOSE=Account verification, referral invite matching, and peer wallet transfers on Quebix backend.`

---

## Technical Scope Limits

1. **Permitted Fields:** Only Display Name and Normalized Phone Numbers (`+91...`).
2. **Excluded Fields:** Profile photos, email addresses, postal addresses, birthdays, notes, organization details, social handles, ringtones, and hidden metadata are strictly excluded.
3. **No Unrequested Outbound Contact:** The application will **never** automatically send SMS messages, emails, or push notifications to imported device contacts without an explicit, user-initiated action.
