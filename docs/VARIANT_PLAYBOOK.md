# Variant Playbook — spin up a new branded app from the base

This turns a fresh copy of the base project into a fully branded, Play-Store-ready
app. Steps marked **[auto]** are scripted; **[manual]** need your input (design,
credentials, console).

> Keep the pristine base (Shop-Panda) untouched. Copy it per variant, then follow
> this file top to bottom. Budget ~30–45 min once you're used to it.

---

## 0. Prerequisites (one-time per machine)
- Flutter SDK, Firebase CLI (`firebase`), FlutterFire CLI (`flutterfire`), Node.js.
- In `tools/`: `npm install` (installs `sharp` + `firebase-admin`).

## 1. Copy the base **[manual]**
- Duplicate the base folder → rename to the new app (e.g. `MandiFresh`).
- Open the copy in your editor. Everything below runs inside it.

## 2. Fill in `brand.config.json` **[manual]**
This one file drives the scripts. Edit:
| Field | Example | Used by |
|---|---|---|
| `displayName` | `"MandiFresh"` | app name everywhere, store art |
| `tagline` | `"Fresh from your local mandi."` | feature graphic |
| `packageId` | `"com.mandifresh.app"` | Android app id |
| `iosBundleId` | `"com.mandifresh.app"` | iOS |
| `supportEmail` | `"support@mandifresh.app"` | support links |
| `firebaseProjectId` | `"mandifresh-xxxx"` | flutterfire / deploy |
| `font` | `"Nunito"` | store art (also set it in the theme, step 4) |
| `palette.*` | hex values | icons + store art |
| `rename.fromNames` | leave as-is for a base copy | rebrand.js |
| `rename.fromPackage` | leave as-is for a base copy | rebrand.js |

## 3. Run the rebrand script **[auto]**
```bash
cd tools
node rebrand.js
```
Renames the app name across `lib/`, `test/`, `web/`, the Android manifest and iOS
plist; sets `applicationId` + `namespace`; relocates `MainActivity.kt`.
> Does NOT rename the internal Dart package (`shop_pandaa`) — that's intentional
> (renaming it would churn every import for zero user-facing benefit).

## 4. Theme — palette + font **[manual]**
Edit two files (the design decision per app):
- `lib/theme/app_colors.dart` — set the palette. Keep the **token names** (`teal`,
  `tealDark`, `surface`, `text`, `bgTop..bgBottom`, the three gradients). Match the
  hexes to `brand.config.json` so the app and the icons agree.
- `lib/theme/app_theme.dart` — set the font (`GoogleFonts.<font>`), light/dark
  brightness, and `ColorScheme`.
- Optional: `lib/widgets/brand_logo.dart` if you want a different in-app logo mark.

## 5. Launcher icon + splash **[auto]**
```bash
cd tools
node generate_icon.js
cd ..
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
Icons/splash use the palette from `brand.config.json`. Pubspec already points at
`app_icon.png` / `app_icon_foreground.png` / `app_icon_background.png`.

## 6. Firebase — new project **[manual + auto]**
1. **[manual]** In the Firebase console (the account for this app): create the
   project, enable **Auth → Email/Password**, and create **Firestore** (production).
2. **[manual]** `firebase login` as the owning account (`firebase projects:list` to confirm).
3. **[auto]** Regenerate config for the new package:
   ```bash
   flutterfire configure --project=<projectId> \
     --android-package-name=<packageId> \
     --ios-bundle-id=<iosBundleId> \
     --platforms=android,ios,web --yes
   ```
4. **[auto]** Ensure `firebase.json` keeps its `firestore` block (rules+indexes),
   then deploy:
   ```bash
   firebase use --add        # alias the new project (first time)
   firebase deploy --only "firestore:rules,firestore:indexes"
   ```
   > If an index deploy complains about a single-field index, remove that entry
   > from `firestore.indexes.json` (Firestore auto-creates single-field indexes).

## 7. Seed the catalog **[manual + auto]**
1. **[manual]** Console → Project settings → Service accounts → **Generate new
   private key** → save as `tools/service-account.json` (git-ignored).
2. **[auto]** `cd tools && node seed_catalog.js`
   > Edit the arrays in `seed_catalog.js` if this variant needs different sample data.

## 8. Store assets **[auto]**
```bash
cd tools && node generate_store_assets.js
```
Produces `tools/playstore/icon_512.png` (512×512) and `feature_graphic.png` (1024×500).

## 9. Build + verify **[auto]**
```bash
flutter clean && flutter pub get
flutter analyze lib
flutter run                       # smoke test on device
flutter build appbundle --release # -> build/app/outputs/bundle/release/app-release.aab
```

---

## Quick checklist
- [ ] Copied base → new folder
- [ ] Edited `brand.config.json`
- [ ] `node rebrand.js`
- [ ] Edited `app_colors.dart` + `app_theme.dart` (palette + font)
- [ ] `node generate_icon.js` + launcher icons + splash
- [ ] Firebase project created (Auth + Firestore enabled), CLI logged in
- [ ] `flutterfire configure` + `firebase deploy --only firestore`
- [ ] `service-account.json` in place + `node seed_catalog.js`
- [ ] `node generate_store_assets.js`
- [ ] `flutter build appbundle --release`
- [ ] Store listing: title, descriptions, screenshots, privacy policy URL
- [ ] Backed up this variant's keystore + passwords

---

## Files that define a variant (know your surface area)
| Concern | File(s) |
|---|---|
| Name / package / palette source | `brand.config.json` |
| App name strings | handled by `rebrand.js` (manifest, plist, `web/index.html`, `lib/app.dart`, brand widgets, etc.) |
| Colors | `lib/theme/app_colors.dart` |
| Fonts / theme | `lib/theme/app_theme.dart` |
| In-app logo mark | `lib/widgets/brand_logo.dart` |
| Launcher icon config | `pubspec.yaml` (`flutter_launcher_icons`, `flutter_native_splash`) |
| Android id | `android/app/build.gradle.kts`, `.../kotlin/**/MainActivity.kt` |
| Firebase | `lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json`, `.firebaserc` |
| Catalog data | `tools/seed_catalog.js` |
| Extra features | feature-specific screens/widgets (per variant) |

---

## ⚠️ Play Store safety (read before shipping multiple apps)
Google suspends developers who publish **near-identical** apps (Spam / Minimum
Functionality / Repetitive Content policies) — this can ban the whole account, not
just one app. Each variant must be **genuinely differentiated**:
- Distinct niche, real different features, different catalog/content, unique branding.
- Unique store listing: own title, descriptions, and **fresh screenshots** per app.
- Own privacy policy URL per app (required — the app collects email + location).
- **Back up each app's keystore + passwords separately.** Losing them means you can
  never update that app again.

Using different Firebase accounts is fine. Using different Play Console accounts does
**not** bypass the spam policy (Google links them) — differentiate for real instead.
