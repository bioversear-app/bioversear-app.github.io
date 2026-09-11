# BioVerseAR — Supabase setup (one-time)

You do these steps (I can't create accounts or type your credentials). Takes ~5 minutes.

## 1. Create the project
1. Go to https://supabase.com → sign in → **New project**.
2. Name it (e.g. `bioversear`), set a database password (save it somewhere), pick the region closest to the Philippines (**Southeast Asia (Singapore)**), Free plan.
3. Wait ~2 min for it to finish provisioning.

## 2. Enable anonymous sign-in
- **Authentication → Sign In / Providers → Anonymous Sign-Ins → turn ON.**
  (This is what lets a student use the app with just an alias — no email or password.)

## 3. Create the tables
- **SQL Editor → New query** → paste the entire contents of `schema.sql` → **Run**.
- You should see "Success. No rows returned." Check **Table Editor** — you'll see `profiles` and `attempts`.

## 4. Send me two values
- **Project Settings → API** (or **Data API**). Copy:
  1. **Project URL** — looks like `https://abcdefgh.supabase.co`
  2. **anon public** key — a long string labeled `anon` / `public`

Paste both here in chat.

### ⚠️ Security note
- The **anon public** key is *designed* to be embedded in a website — it's safe to share, and Row-Level Security (in `schema.sql`) protects the data. This is the one I need.
- **Never** share the **`service_role`** key (also on that page). It bypasses all security. If you ever paste it anywhere by accident, rotate it in the dashboard.

That's it — once you send the URL + anon key, I'll wire the app to it and we'll test the cloud leaderboard live.
