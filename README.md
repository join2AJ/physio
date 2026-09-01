# Dr. Vikas Patient Monitoring System

A single-file web app for a physiotherapy clinic to log patient visits, track
visit status and payments, record diagnoses, and view reports and charts. Data
is stored securely in the cloud (Supabase) so it syncs across phone, tablet and
computer, and each clinic account only ever sees its own records.

## Files

| File | What it is |
|------|------------|
| `index.html` | The whole app — open it in a browser or host it anywhere. |
| `schema.sql` | Run once in Supabase to create the table + security rules. |
| `REVIEW.md` | Plain-English review of the original versions and what changed. |

## First-time setup (about 10 minutes)

1. **Create a Supabase project** at [supabase.com](https://supabase.com) (free tier is fine).
2. **Create the database table.** In the project: **SQL Editor → New query**, paste the
   contents of `schema.sql`, and click **Run**. This creates the `visits` table
   and — importantly — the Row Level Security rules that keep each account's data private.
3. **Get your keys.** In **Project Settings → API**, copy:
   - the **Project URL** (looks like `https://xxxx.supabase.co`), and
   - the **anon / publishable** key.
4. **Put them in `index.html`.** Near the top of the `<script>` block, set:
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";      // base URL only — no /rest/v1/
   const SUPABASE_ANON_KEY = "your-anon-publishable-key";
   ```
5. **(Recommended) Email confirmation.** In **Authentication → Providers → Email**,
   decide whether new accounts must confirm their email. The app handles both cases.
6. **Host the file.** Upload `index.html` to any static host — GitHub Pages,
   Netlify, Vercel, or Cloudflare Pages all work and are free. Open the URL,
   click **Create Account**, and you're live.

> **Is it safe to publish the anon key in the file?** Yes. The anon key is
> designed to be public; your data is protected by the Row Level Security
> policies in `schema.sql`, not by hiding the key. **Never** put the
> `service_role` key in this file, though — that one bypasses all security.

## Using the app

- **Daily Log tab** — add a date, add patients under it, and fill in name,
  diagnosis, status and amount. Everything auto-saves to the cloud.
- **Reports & Charts tab** — monthly summary, custom date-range analytics,
  revenue/visits charts, most-common-diagnoses, and a status breakdown.
- **Export CSV** — download all records for backup or to open in Excel.

## Features at a glance

- Secure multi-device cloud sync with per-account privacy.
- Patient visits grouped by date, with status and per-visit reason for no-shows.
- **Diagnosis** field on every visit.
- Reports: total patients & revenue **per month** and **per custom date range**,
  sessions per patient, and most common diagnoses.
- Graphical charts (revenue by month, visits by month, status breakdown).
- CSV export and a live "Synced / Saving / Save failed" indicator.
