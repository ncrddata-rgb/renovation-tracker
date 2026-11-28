# Developer handover: House Renovation App

The live app is at **https://our-house-renovation.web.app**. It's a single-page web app with no framework and no build tools. It uses Firebase for Google sign-in and the database.

> No passwords, private keys or service-account files belong in this repo. The values in `config.js` are Firebase's public web settings and are safe to commit. The Firestore rules are what protect the data.

---

## 1. Files

| Path | What it is |
|---|---|
| `src/app.html` | **The source.** All CSS, HTML and JavaScript for the app in one file. Edit this. |
| `index.html` | **Built output** that the website serves. Never edit it by hand: run `sh build.sh` after changing `src/app.html`, and commit both files. |
| `build.sh` | Wraps `src/app.html` in the `<html>`, `<head>` and `<body>` shell and writes `index.html`. |
| `config.js` | `window.RENO_CONFIG`: Firebase web settings, `appUrl` (used in share and invite links), `projectName`, `deadline`. |
| `seed.js` | `window.SEED`: the original 21 aspects and 85 items from the owner's Excel plan. It's used to fill an empty database the first time, and for the demo. |
| `vendor/` | Self-hosted libraries, loaded only when needed: jsPDF 2.5.1 with autotable 3.8.2 (report PDFs) and SheetJS 0.18.5 (Excel downloads). |
| `firestore.rules` | Database access rules. **The repo copy has the placeholder `OWNER_GMAIL@gmail.com`**, so the owner's email isn't published. See section 4. |
| `firebase.json`, `.firebaserc` | Firebase Hosting config: site `our-house-renovation`, project `our-house-renovation-app`, and no-cache headers so users always get the latest version. |
| `.github/workflows/firebase-hosting.yml` | Auto-deploy to Firebase Hosting on every push to `main`. |
| `.nojekyll` | The same files are also served by GitHub Pages as a backup mirror (https://ncrddata-rgb.github.io/renovation-tracker/). |

### Inside `src/app.html`

All the code is one `<script>`, wrapped in an IIFE. Rough order, top to bottom:

1. **Constants:** `STATUSES` (planned / progress / hold / done, labelled Not Started / In progress / On hold / Completed), `FLOORS`, `TRADES`, `ROLES`.
2. **Stores**, which share the same interface, so the views never care which one is in use:
   - `DemoStore()` keeps everything in `localStorage` (`reno-demo-v2`). It's used when `config.js` has no `apiKey`.
   - `FirebaseStore()` is the live store. It loads Firebase JS SDK 10.12.2 from gstatic, then provides Google sign-in, real-time `onSnapshot` listeners and the writes.
3. **`state`**: the app's in-memory data (`items`, `aspects`, `members`, `settings`, `thumbs`, the signed-in user and their member record).
4. **Permissions:** `role()` and the `can` object (`editAll`, `editProgress`, `deleteItem`, `deleteAspect`, `members`, `addNew`).
5. **Routing:** `VIEWS` (the tab list), `visibleViews()` (hides Owner-only tabs), `currentView()` (hash routing, so `#items`, `#team` and so on; unknown or forbidden tabs fall back to Dashboard) and `render()`.
6. **One function per tab:** `viewDashboard`, `viewAspects`, `viewItems`, `viewBoard`, `viewPhotos`, `viewTimeline`, `viewReports`, `viewTeam`.
7. **Dialogs and helpers:**
   - `openItem` (the item dialog)
   - change logging (`logChanges`, `parseChange`)
   - photos and thumbnails (`shrink`, `makeThumb`, `refreshThumb`)
   - share and invite (`openShare`, `shareInvite`, `inviteText`)
   - reports (`buildReport`, `downloadReportPdf`, `downloadReportExcel`)
   - Hide/Show sections (`secHead`, `wireHide`; every section starts hidden)
   - the Owner reset (`confirmResetStatus`, `downloadResetBackup`, `store.resetStatus`)

---

## 2. Firebase

- **Project:** `our-house-renovation-app`
- **Hosting site:** `our-house-renovation`, served at https://our-house-renovation.web.app
- **Sign-in:** Google only. Anyone can sign in, but they see nothing unless their email is on the Team list.

### Firestore collections

| Collection | Document ID | Contents |
|---|---|---|
| `members` | lower-case email | `name`, `role`, `trade`, `phone`, `disabled` |
| `aspects` | auto, or `a01`…`a21` from the seed | `name`, `floor`, `order`, `notes` |
| `items` | auto, or `a01-01`… from the seed | `aspectId`, `title`, `nextSteps`, `contact` (a member's email), `trade`, `floor`, `status`, `progress`, `daysRequired`, `plannedStart`, `plannedEnd`, `actualDate`, `estimate`, `actualSpent`, `priority`, `order`, `updatedBy`, `updatedAt` |
| `comments` | auto | `itemId`, `by`, `at`, `kind` (`comment` = a note, `change` = automatic change log), `text`, `changes` (structured `{field: [from, to]}` on newer change entries) |
| `photos` | auto | `itemId`, `kind` (before/after), `by`, `at`, `data` (a downscaled JPEG data URL, under 900 KB) |
| `thumbs` | item ID | `data` (a 96 px JPEG of the item's newest photo), `photoId`, `by`, `at`. If the rules block it, the app builds thumbnails from `photos` instead. |
| `settings` | `main` | `projectName`, `deadline`, `budget` |

### Roles and permissions

| Role | In the app |
|---|---|
| **Owner** | Everything. Only Owners see the **Team** and **Reports** tabs, add aspects or items, manage the team, change settings, and use **Reset status data**. |
| **Manager / Engineer** | Edit any aspect or item, including dates and money. Can't add aspects or items. |
| **Contractor** | Update status, progress, next steps and completion date. Add photos and notes. |
| **Family** | View everything. Add photos and notes. |

The UI checks are in `can` and `visibleViews()`. The real enforcement is in `firestore.rules`, so keep the two in step whenever you change permissions.

---

## 3. How deploys work

**Push to `main` and it's live within about a minute.** No keys are needed on your machine.

- **Firebase Hosting:** `.github/workflows/firebase-hosting.yml` runs on every push to `main` (it can also be started by hand from the Actions tab). It deploys with `FirebaseExtended/action-hosting-deploy` and the repository secret **`FIREBASE_SERVICE_ACCOUNT`**, which is already set up. If that secret is ever removed, the workflow skips the deploy instead of failing.
- **GitHub Pages:** the mirror updates from `main` automatically.
- Check a deploy in the repo's **Actions** tab. "Publish to Firebase Hosting" should be green.
- `firebase.json` sends `Cache-Control: no-cache` for `/`, `*.html` and `*.js`, so users get new versions without a hard refresh.

**Checklist for every change:** edit `src/app.html`, run `sh build.sh`, test locally, then commit `src/app.html` and `index.html` together and push to `main`.

---

## 4. Firestore rules (not auto-deployed)

The workflow deploys hosting only. Rules are published by hand, so that a typo can't lock everyone out.

1. Copy `firestore.rules` and replace `OWNER_GMAIL@gmail.com` with the owner's Gmail address in lower case. **Don't commit that change.**
2. In the Firebase console, open **Firestore Database**, then **Rules**. Paste in the edited file and click **Publish**.
   - Or, with your own Firebase login and the Firebase CLI: add `"firestore": { "rules": "firestore.rules" }` to a local copy of `firebase.json`, then run `firebase deploy --only firestore:rules --project our-house-renovation-app`.
3. Use the console's **Rules Playground** to test a change before publishing it.

The rules published today match the repo file, with the owner's email filled in.

---

## 5. Run it locally

```sh
sh build.sh
python3 -m http.server 8000      # or any static server
# open http://localhost:8000
```

- **Demo mode (safe, no real data):** in a local copy of `config.js`, set `apiKey: ""` and don't commit it. All data then lives in the browser's `localStorage`. Clear it to start over.
- **Live mode:** keep `config.js` as it is. Google sign-in works on `localhost` (it's an authorised domain by default). **You'll be editing the real project data**, so be careful, and never press *Reset status data* while testing.

---

## 6. Common changes

**Add a tab**
1. Add `{ id: 'mytab', label: 'My tab' }` to `VIEWS`. Its position there is its position in the menu.
2. Write `function viewMyTab(main) { main.innerHTML = '…'; }`.
3. Register it in the map inside `render()`: `mytab: viewMyTab`.
4. To make it Owner-only, add its ID to `OWNER_VIEWS`.

**Change what a role can do**
- UI: edit the `can` object, or `ROLES` for labels and descriptions, and the "What each role can do" table in `viewTeam`.
- Database: edit the matching `match` block in `firestore.rules`, then publish it (section 4).

**Add a field to items**
1. Add it, with a default value, to `blankItem()`.
2. Add an input to the item dialog in `openItem`, and include it in the saved `patch`.
3. Add a label in `logChanges` so changes to it show in the history.
4. If contractors should edit it, add it to `contractorFieldsOnly()` in the rules.

**Status names or colours:** edit `STATUSES`. The stored values (`planned`, `progress`, `hold`, `done`) must not change, because existing data uses them. Only change labels and colours.

**Floors and trades lists:** edit `FLOORS` and `TRADES`.

**Invite message, share link, project name or deadline defaults:** `inviteText()`, `APP_URL`/`SHARE_LINK`, and `config.js`.

**Libraries:** the CDNs may be blocked on some networks. To use a new library, download it into `vendor/` and load it with `loadScript('vendor/…')`, as the reports do.

---

## 7. Things to know

- Photos are stored inside Firestore documents as compressed data URLs. There's no Cloud Storage bucket. `shrink()` keeps each one well under Firestore's 1 MB document limit.
- The item change log is written by the client (`logChanges`) whenever status, progress, dates, money or the contact changes. Reports are built from it.
- **Reset status data** (Team tab, Owner only) clears these fields on every item, using a field-level `update()`: status, progress, priority (back to Normal), dates, estimate, spent and contact. It also deletes everything in `comments`, `photos` and `thumbs`. Aspects, item details, members and settings are never touched. It downloads an Excel backup first.
- **Full backup** (Team tab, Owner only) downloads the whole project read-only as `full-backup-<date>.xlsx` (readable) and `.json` (complete, including photos). **Keep those files out of this public repo.**
- The owner's EmailJS automatic invite emails are coded but switched off. They need `emailjs.serviceId`, `templateId` and `publicKey` in `config.js`. Until then, invites go out through the WhatsApp, Telegram, Email and Copy link menu.
