# CLAUDE.md: House Renovation App

Context and rules for Claude Code when working in this repository. **Read `HANDOVER.md` first.** It covers the architecture, the data model, roles, deploys and recipes for common changes. `docs/PROJECT_HISTORY.md` is the dated log of everything built so far and why.

## What this is

A private progress tracker for a G+2 house renovation with a terrace in Hyderabad, with hand-over on 25 Dec 2026.

- **Live app:** https://our-house-renovation.web.app (Firebase Hosting).
- **Backup mirror:** GitHub Pages.
- **Data:** Firebase project `our-house-renovation-app`, with Google sign-in and Firestore.
- **Seed:** 21 aspects and 85 items from the owner's Excel plan (`seed.js`).

## How to work here

- **Edit `src/app.html` only**, then run `sh build.sh` to regenerate `index.html`. Commit both files together. Never hand-edit `index.html`.
- **Code style:**
  - Plain vanilla JS in one file, with no framework, bundler or npm dependencies.
  - Keep it that way unless the owner asks otherwise.
  - Match the existing style: small helpers, template-string HTML, and `esc()` on every user value put into HTML.
- **Libraries:** they live in `vendor/` and are loaded lazily with `loadScript()`. Don't add CDN script tags.
- **Deploy:** push to `main`. GitHub Actions deploys to Firebase Hosting with the `FIREBASE_SERVICE_ACCOUNT` repo secret, and GitHub Pages updates too. Check the Actions tab afterwards.
- **Test before pushing.**
  - Demo mode: in a local copy of `config.js`, set `apiKey: ""` and don't commit it. Then serve the folder, for example with `python3 -m http.server`.
  - Click through the affected tabs as Owner, Manager and Contractor. In demo mode you can switch the signed-in member in `localStorage` (`reno-demo-v2`, key `meEmail`).
  - Check desktop and phone widths.
- **Permissions have two layers.** Keep the UI (`can`, `visibleViews()`, `OWNER_VIEWS`) and `firestore.rules` in step. Rules are **published by hand** in the Firebase console; see HANDOVER section 4.

## Never do this

- **Never run "Reset status data" on the live project**, and never write scripts that bulk-change or delete live Firestore data, unless the owner explicitly asks in so many words. Test destructive features on demo data only.
- **Never commit secrets:** no service-account JSON, private keys, tokens or passwords. The values in `config.js` are public Firebase web settings and are fine.
- **This repo is public.** Never commit personal data:
  - team members' emails or phone numbers;
  - the owner's email (`firestore.rules` uses the placeholder `OWNER_GMAIL@gmail.com`; the filled-in copy is published only in the console);
  - Firestore exports and backups;
  - photos.
- **Never change stored status values** (`planned`, `progress`, `hold`, `done`) or existing field names. Live data depends on them. Labels are safe to change.
- **Never recreate or overwrite documents** where a field-level `update()` will do. Item, aspect and member IDs must stay stable.

## The owner's preferences (keep these)

- Clean, professional, subtle styling: tinted section headings with a left accent bar, consistent spacing, and evenly aligned columns. No loud colours.
- Every Hide/Show section **starts hidden** on each page open or refresh, with no remembered state.
- **Owner-only:**
  - Team and Reports tabs;
  - Share;
  - adding aspects and items;
  - Reset status data;
  - Full backup.
  Managers and Engineers can edit existing aspects and items. Contractors update status and progress. Family can view, and add notes and photos.
- **Status labels:** Not Started, In progress, On hold, Completed.
- **Tab order:** Dashboard, Aspects, Items, Board, Photos, Timeline, Reports, Team.
- **Share and invite links** always use `https://our-house-renovation.web.app`. Keep the invite text exactly as it is in `inviteText()`.
- The owner isn't a developer. Explain things in plain words, with click-by-click steps, and confirm before anything that changes live data or settings.

## Open items when development was handed over (25 Nov 2026)

- **Automatic invite emails (EmailJS):** the code is in place but switched off until `config.js` gets `emailjs: { serviceId, templateId, publicKey }`.
- **Reset and photos:** the owner once said uploaded images should stay unchanged on reset, while an earlier request asked for photos to be deleted. Reset currently deletes photos (after backing them up). Confirm with the owner before changing it.
