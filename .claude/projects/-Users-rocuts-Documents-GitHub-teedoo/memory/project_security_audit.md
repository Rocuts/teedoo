---
name: Security audit 2026-04-08
description: Comprehensive security audit with 15+ findings — critical API key exposure, token storage, demo credentials, data masking
type: project
---

Full security audit performed 2026-04-08. Key findings and fixes applied:

**CRITICAL (fixed in code):**
- Demo credentials were exposed in error messages → removed
- Tokens stored in plaintext SharedPreferences → migrated to flutter_secure_storage
- Unsafe null unwraps in router/services → replaced with safe alternatives
- NIF/IBAN displayed unmasked in UI → added masking functions
- Dev server CORS was `*` → restricted to localhost origins
- Report template accepted arbitrary keys → added allowlist + size limit

**CRITICAL (requires manual user action):**
- OpenAI API key in .env must be REVOKED and regenerated at platform.openai.com
- .env has DEMO_AUTH_ENABLED=true — must be false for production builds

**Why:** App handles sensitive financial data (NIFs, IBANs, tax info) for Spanish businesses — security is compliance-critical.

**How to apply:** Any future auth/token/data-display work should follow the secure storage pattern and masking utilities established in this audit.
