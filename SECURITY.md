# Security & Compliance Notes — Patient Monitoring System

This document describes the **technical security controls** built into the app and
maps them to common frameworks (ISO/IEC 27001, ISO 31000, NIST CSF). It also lists,
honestly, what the **app cannot do on its own** — the organizational steps a clinic
must take before this holds real patient data.

> **Important, read first.** No software is "ISO 27001 certified" by itself.
> Certification and true compliance are about an organization's *processes*
> (policies, risk assessments, staff training, incident response, audits).
> The code here implements many of the *technical* controls those frameworks
> expect; the rest is the clinic's responsibility. Treat this as a strong
> starting point, not a certificate.

Because this system stores **health data about identifiable patients**, in India it
falls under the **Digital Personal Data Protection Act, 2023 (DPDP)**, and elsewhere
under laws such as GDPR/HIPAA. Get local legal/privacy advice before going live.

---

## 1. Controls implemented in the app / database

| Control | How it's done | Framework mapping |
|---|---|---|
| **Authentication** | Supabase email + password; no access without a valid session | ISO 27001 A.5.15/A.5.16; NIST **PR.AA** |
| **Access control (per-user isolation)** | Row Level Security on every table — each account can only read/write **its own** rows; proven with a live test (anonymous insert → HTTP 401) | ISO 27001 A.5.15/A.8.3; NIST **PR.AA/PR.DS** |
| **Encryption in transit** | All traffic over HTTPS/TLS to Supabase and the host | ISO 27001 A.8.24; NIST **PR.DS-2** |
| **Encryption at rest** | Supabase/Postgres encrypts stored data at rest by default | ISO 27001 A.8.24; NIST **PR.DS-1** |
| **Audit trail / logging** | `audit_trail.sql` records every add/edit/delete with user, timestamp and before/after snapshot; **append-only** (no user policy to edit or delete log rows) | ISO 27001 A.8.15; NIST **PR.PT / DE.AE** |
| **Input validation** | New-visit form validates required name, numeric non-negative amount, no future dates, mandatory reason for no-shows | ISO 27001 A.8.28; NIST **PR.PS** |
| **Least-privilege keys** | App ships only the **public** publishable key; the **secret** key is never in the client | ISO 27001 A.8.2; NIST **PR.AA-5** |
| **Secure output handling** | User text is HTML-escaped before display (reduces script-injection risk) | ISO 27001 A.8.28 |
| **Data export / portability** | CSV export lets the clinic back up or move its data | ISO 31000 (continuity); NIST **RC.RP** |

---

## 2. Gaps the CLINIC must close (not solvable in code alone)

These are the honest "not done yet" items. Prioritised.

1. **Rotate the leaked secret key.** A `sb_secret_...` key was shared in chat during
   setup — regenerate it in Supabase → Project Settings → API Keys. *(ISO 27001 A.5.17)*
2. **Multi-factor authentication (MFA).** Enable MFA in Supabase Auth for logins.
   A password alone is weak for medical data. *(NIST PR.AA-3)*
3. **Backups & recovery.** Turn on Supabase automated backups (the dashboard showed
   "No backups"). Test a restore. Keep an off-site CSV copy. *(ISO 27001 A.8.13; NIST RC.RP)*
4. **Password policy & account lifecycle.** Strong passwords, disable public sign-up,
   remove staff who leave, review who has access quarterly. *(ISO 27001 A.5.16/A.5.18)*
5. **Data retention & deletion policy.** Decide how long records are kept and how a
   patient can request erasure (DPDP/GDPR right). *(ISO 27001 A.5.34; DPDP)*
6. **Consent & privacy notice.** Tell patients what you store and why; record consent.
   *(DPDP; GDPR Art. 13)*
7. **Incident response plan.** A written "what we do if data leaks" procedure, plus
   breach-notification obligations. *(ISO 27001 A.5.24–A.5.26; NIST RS/RC)*
8. **Data Processing Agreement with Supabase** and confirm the hosting **region**
   (your project is in Singapore — check this is acceptable for Indian patient data).
   *(ISO 27001 A.5.19–A.5.23; DPDP cross-border rules)*
9. **Business continuity.** What happens if Supabase or Netlify is down. *(ISO 31000)*
10. **Periodic review / penetration test** before wider rollout. *(ISO 27001 A.8.8/A.8.29)*

---

## 3. ISO 31000 — starter risk register

A minimal risk table to begin the ISO 31000 "identify → analyse → treat" cycle.
Expand and review it regularly with the clinic.

| Risk | Likelihood | Impact | Treatment |
|---|---|---|---|
| Stolen/guessed password → data exposed | Medium | High | Enable MFA; strong password policy |
| Leaked secret key → full data access | Medium (one was shared) | High | Rotate key now; never expose secret keys |
| Data loss (no backups) | Medium | High | Enable automated backups; off-site CSV |
| Device with saved login lost/stolen | Medium | Medium | Auto sign-out; MFA; remote session revoke |
| Cross-border data / legal non-compliance | Medium | High | Confirm region, DPA, consent, legal review |
| Staff misuse of records | Low | High | Audit trail (built) + access reviews |

---

## 4. How to install the technical controls

1. Run `schema.sql` — core tables + Row Level Security. *(done)*
2. Run `audit_trail.sql` — the audit log + trigger. **(new — run this)**
3. In Supabase dashboard: enable **MFA**, **automated backups**, disable public
   **sign-up**, and confirm the **region** and a signed **DPA**.
4. Rotate the exposed **secret key**.

After step 2, open the app → **Reports & Charts → Activity Log** to see the audit
trail populate as you add or edit visits.

---

*This is technical guidance, not legal advice. For real patient data, have a
qualified privacy/security professional review the full setup.*
