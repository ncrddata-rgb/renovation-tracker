# Project history

A dated log of what was built and decided, oldest first. Times are UTC (India is UTC+5:30). `git log` has every individual commit.

## 24 Nov 2026: first version and sharing

- **Requirements and first build.** The owner's Excel plan (21 aspects, 85 items) became `seed.js`. The app had Google sign-in, five roles (Owner, Manager, Engineer, Contractor, Family), and these tabs: Dashboard, Items, Board, Timeline, Aspects, Team. Aspects can be added later.
- **Connected to Firebase.** Project `our-house-renovation-app`. The first sign-in of the owner email named in the rules creates the Owner record.
- **GitHub Pages fix.** Pages didn't load at first because the repo was private. The owner made it public and enabled Pages.
- **Share panel (Owner only).** Invite by email and role, a "People with access" list with a role dropdown and remove, plus WhatsApp, Telegram, Email and Copy link.
- **Automatic invite emails** through EmailJS (free plan). The code is in place but still dormant, waiting for the owner's three EmailJS IDs.
- **Photos page.** Grouped by aspect, with filters and upload. Photos are stored as compressed data URLs in Firestore.
- **Money.** Explained the dashboard totals. The money tiles open lists (Estimated, Spent) and a budget breakdown, and the Owner can set the overall budget.
- **Dashboard "Due in the next N days".** Dropdown, extended in steps to 1–30 days, default 7.
- **Labels.** "Planned" became "Not Started" (the stored value is still `planned`).
- **Hide/Show** buttons on dashboard sections.
- **Wording.** "Money" became "Budget Overview".
- **Section headings** restyled: a subtle tinted band with a left accent bar, at the owner's request for less visual noise.
- **Firebase Hosting.** The app moved to https://our-house-renovation.web.app, with a GitHub Actions workflow publishing on every push to `main`. Share, invite and Copy link always use that address.
- **Invite menu** cut down to WhatsApp, Telegram, Email (opens Gmail on the web) and Copy link. The invite text uses the owner's exact wording, starting "Hi! 😊".
- **Team tab** shown to Owners only; others are redirected.
- **Title** became "House Renovation App". Removed "+ Add item" from the Dashboard.
- **Sign-in issue on Android.** It came from tapping the email address in an old invite, not from an app bug.

## 25 Nov 2026: reports, thumbnails, permissions, reset

- **Labels.** "Done" became "Completed" (the stored value is still `done`).
- **Tab order:** Dashboard, Aspects, Items, Board, Photos, Timeline, Reports, Team.
- **Daily and weekly progress reports** (Reports tab):
  - sections for completed, in progress, on hold, challenges and delays, pending, notes, completed per day, and accountability by person;
  - download as PDF or Excel, Copy for WhatsApp, Print;
  - built from the item change log (`comments` with `kind: 'change'`).
- **Hide/Show** added to the report sections. Later rule: **every Hide/Show section starts hidden** on every page open or refresh, with no remembered state.
- **Photo thumbnails** beside each item everywhere it appears: Dashboard, Items, Board, Timeline, Budget lists and Reports.
  - They're stored in a `thumbs` collection.
  - If the rules don't allow `thumbs`, the app builds thumbnails in the browser from `photos`.
  - Polish: on the Items page they sit in their own aligned column, spaced exactly like the contact and date columns. They're a uniform 44 px, cropped (not stretched), with rounded corners.
- **Reset status data (Owner only, Team tab).** Built up over several requests. On every item it clears:
  - status (back to Not Started) and progress (back to 0%);
  - priority (back to Normal; added 25 Nov at the owner's request);
  - planned start, due date and completion date;
  - estimate and amount spent;
  - who the item is assigned to.

  It also deletes the progress updates and notes, the change history, and photos and thumbnails.
  - Safety: type RESET to confirm, and a backup downloads first.
  - It uses field-level updates only, so aspects, item details, the team and settings are never touched.
  - Afterwards it checks against the server and asks the Owner to retry if anything was left.
  - If there's nothing to clear, it does nothing, so there's no empty backup.
- **Reset backup format.** Changed from raw JSON to an organised Excel file (Summary, Items including old priority, Updates and history, Photos), plus a photos JSON when there are photos. The owner's first real backup was converted for them.
- **Caching fix.** The site root was cached for up to an hour after deploys, so people kept seeing old versions. `firebase.json` now sends `no-cache` for `/`.
- **Removed** the Items page "Export to Excel (CSV)" button.
- **Reports tab** shown to Owners only; others are redirected.
- **Adding aspects and items is now Owner-only**, in both the UI and the rules. The owner published the updated rules.
- **Developer handover.** Added `HANDOVER.md`, `CLAUDE.md`, this history, and an Owner-only **Full backup** button on the Team tab. It downloads the whole project (aspects, items, team, settings, history, photos) as Excel and JSON and changes nothing.

## Known caveats

- Photos live inside Firestore documents (each under 900 KB after downscaling), not in Cloud Storage.
- The rules in the repo use a placeholder owner email. The published rules contain the real one and are updated by hand.
- EmailJS invites stay off until it's configured.
- Some older change-log entries are text-only and use the old labels ("Planned", "Done"). `parseChange()` and the backup export handle both.
