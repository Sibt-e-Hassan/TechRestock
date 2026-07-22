# Google Play Console — Master Playbook

Use this document to fill in **every Play Console section in one pass** for any Flutter app — without screenshot-by-screenshot back and forth.

---

## Master agent prompt (paste into another Cursor / Claude chat)

Copy everything below into a new chat for your **other Flutter project**:

```
You are helping me complete Google Play Console setup for this Flutter app.

1. Read docs/PLAY_STORE_PLAYBOOK.md (or this pasted document if the file is not in the repo).
2. Work through **Appendix A — Complete Play Console checklist** in order. Do not skip any item.
3. Inspect this codebase before answering:
   - android/app/build.gradle.kts → applicationId
   - android/app/src/main/AndroidManifest.xml → permissions, label
   - pubspec.yaml → SDKs (ads, analytics, payments, location)
   - lib/screens/auth/ → sign-in method, account creation
   - firestore.rules or backend rules → is login required?
   - lib/services/location_service.dart or geolocator usage
   - lib/config/legal_urls.dart → privacy, terms, support, deletion URLs
   - web_docs/ → hosted legal pages (privacy, terms, support or delete)
   - firebase.json + .firebaserc → hosting project
   - android/key.properties.example → release signing setup
   - Profile/account screens → in-app account deletion flow
4. For EVERY section (Create app → Store listing → Store settings → App content → Release), output a table with:
   - Section name
   - Recommended answer (Yes/No or exact text to paste)
   - One-line reason tied to this app's code
   - Copy-paste value (when applicable)
5. Give copy-paste ready values: app name, package name, short description, full description, URLs, emails, test account (if needed), and all questionnaire answers.
6. Do not skip any section listed in the playbook or Appendix A, even if I did not provide a screenshot.
7. Flag prerequisites that must exist first: live privacy policy URL, account deletion/support page, Firebase test reviewer account, release keystore (key.properties + .jks), firebase deploy --only hosting.
8. If legal_urls.dart points to Firebase but pages are not deployed, say so and give deploy steps.
```

Replace `[New App Name]` with your app when you paste.

---

## Part 0 — Codebase inspection checklist (any Flutter app)

Before answering Play Console questions, the agent should read:

| What | Where to look |
|------|----------------|
| **Package name / applicationId** | `android/app/build.gradle.kts` → `applicationId` |
| **App display name** | `android/app/src/main/AndroidManifest.xml` → `android:label`; `ios/Runner/Info.plist` → `CFBundleDisplayName` |
| **Privacy policy URL** | `lib/config/legal_urls.dart` or similar; `web_docs/privacy/` |
| **Terms URL** | `lib/config/legal_urls.dart`; `web_docs/terms/` |
| **Account deletion URL** | `lib/config/legal_urls.dart`; `web_docs/delete/` or `web_docs/support/` |
| **Support page URL** | `lib/config/legal_urls.dart`; `web_docs/support/` |
| **Firebase Hosting** | `firebase.json`, `.firebaserc`, `web_docs/` |
| **Release signing** | `android/key.properties.example`, `android/app/build.gradle.kts` signingConfigs |
| **Support email** | `lib/config/legal_urls.dart`; privacy policy HTML |
| **Auth method** | `lib/screens/auth/` — email/password, Google, OAuth, etc. |
| **Location collection** | `geolocator`, `location_service.dart`, Android/iOS permissions in manifests |
| **Ads** | Search `admob`, `google_mobile_ads`, `facebook_audience` in `pubspec.yaml` / `lib/` |
| **In-app purchases / payments** | Search `in_app_purchase`, `stripe`, `razorpay`, checkout flows |
| **User-generated content** | Reviews, posts, chat, uploads |
| **Online / dynamic content** | Firestore/API-loaded catalog vs static `static_catalog.dart` |
| **Account deletion in-app** | Profile screen delete account flow |
| **Firebase / third parties** | `pubspec.yaml`, `firebase_options.dart`, privacy policy text |

---

## Part 1 — Create app (first-time setup)

**Path:** Play Console → **Create app**

| Field | What Google asks | How to decide | Dukaan Dhoondo example |
|-------|------------------|---------------|------------------------|
| **App name** | Name on store (30 chars max) | Brand name users recognize | `Dukaan Dhoondo` |
| **Default language** | Primary listing language | Usually English (United States) | English (United States) — en-US |
| **App or game** | Type of app | Shopping/discovery = **App** | **App** |
| **Free or paid** | Monetization | Cannot change free→paid after publish | **Free** |
| **Package name** | Permanent Android ID | Must match `applicationId` in Gradle **exactly** | `com.dukaandhoondo.app` |
| **Declarations** | Policy + export compliance | Check both boxes | Check both → **Create app** |

**Rules:**
- Package name **cannot be changed** after creation.
- Click **Check availability** on package name before submitting.

### Part 1 addendum — Declarations (before Create app)

On the final Create app screen, check both boxes:

| Declaration | Action |
|-------------|--------|
| **Confirm app meets Developer Program Policies** | Check |
| **Accept US export laws** | Check |

Then click **Create app**. Without both checked, the button stays disabled.

---

## Part 2 — Store listing (Grow users → Store presence → Main store listing)

| Field | Limit / notes | How to decide | Dukaan Dhoondo example |
|-------|---------------|---------------|------------------------|
| **App name** | 30 chars | Same as create app | `Dukaan Dhoondo` |
| **Short description** | 80 chars max | One line value proposition | See below |
| **Full description** | 4000 chars max | Features, disclaimer, privacy summary | See below |
| **App icon** | 512×512 PNG, 32-bit, no alpha | From `store/icon_512.png` | `store/icon_512.png` |
| **Feature graphic** | 1024×500 PNG/JPEG, no alpha | Banner for store | `store/feature_graphic.png` (or Gemini asset in repo) |
| **Phone screenshots** | 2–8 images | Real device captures | Export from app on device |
| **App category** | Primary category | Match main purpose | **Shopping** |
| **Email** | Store contact | Must monitor; use support email in app | `shahabudinghori804@gmail.com` |
| **Privacy policy URL** | Required HTTPS | Must match in-app legal links | `https://dukaan-dhoondho.web.app/privacy` |
| **Website** | Optional | Marketing site if any | Optional / omit |

**Note:** `store/play-store-listing.md` lists `raxyshan@gmail.com` — **outdated**. Use `shahabudinghori804@gmail.com` from `lib/config/legal_urls.dart`.

### Dukaan Dhoondo — Short description (68 chars)

```
Search local markets, browse shops and products, and send inquiries.
```

### Dukaan Dhoondo — Full description

```
Dukaan Dhoondo helps you search local markets, shops, and products across Pakistan and send inquiries to sellers — all from one app.

Browse markets such as Anarkali Bazaar in Lahore, Saddar Market in Karachi, Centaurus Mall in Islamabad, and Husain Agahi Bazaar in Multan. Open any market to explore the shops inside it, view their products, and reach out to the ones you are interested in.

WHAT YOU CAN DO

• Discover markets: Browse markets by city and see how many shops each one lists.

• Explore shops: Open a market to view its shops grouped by category, including clothing, electronics, gems, fragrances, food and spices, and home and decor.

• View products: See product listings with photos, reference prices, and the shop each item belongs to.

• Search: Find shops and products across all markets by name or tag.

• Choose quantities: Set how many of an item you want, on the product page or right in your cart.

• Save to cart: Add products you like to your cart to keep track of them in one place.

• Send inquiries: Submit your saved items as an inquiry so shops can follow up with you. Inquiries are non-binding.

• Manage your account: Sign up with your email, update your profile, and delete your account and data at any time from within the app.

• Find markets near you: Optionally allow location access to see markets in your city first.

PLEASE NOTE

Dukaan Dhoondo is a discovery and inquiry app. It does not process payments, checkout, or delivery. Prices are shown for reference only, and any purchase is arranged directly between you and the shop.

An internet connection is required to load market and shop information.

PRIVACY

We use Firebase Authentication to sign you in and Cloud Firestore to store your profile, cart, and inquiries. We do not sell your data. You can delete your account and associated data at any time from the app, or by contacting us. See our Privacy Policy and Account Deletion pages for details.

We are continuing to add more markets, shops, and products over time. If you have feedback or questions, contact us at shahabudinghori804@gmail.com.
```

### Part 2 addendum — Required store graphics (any app)

| Asset | Spec | Notes |
|-------|------|-------|
| **App icon** | 512×512 PNG, 32-bit, max 1024 KB | Often exported from `assets/images/app_icon.png` |
| **Feature graphic** | 1024×500 PNG or JPEG | Store banner; no alpha channel |
| **Phone screenshots** | Minimum **2**, recommended **4–8** | Portrait 1080×1920 or similar; capture Home, detail, cart, profile |
| **7-inch tablet screenshots** | Optional | Only if targeting tablets |
| **10-inch tablet screenshots** | Optional | Only if targeting tablets |

---

## Part 2b — Store settings (Grow users → Store presence → Store settings)

Separate from **Main store listing**. Controls category, public contact info, and external marketing.

| Field | How to decide (any app) | Notes |
|-------|-------------------------|-------|
| **App category** | Match primary purpose: Shopping, Lifestyle, Business, etc. | Same as listing category |
| **Tags** | Pick closest Play tags (e.g. Shopping, Local, Marketplace) | Optional but helps discovery |
| **Email address** | **Required** — same support email as app + privacy policy | Must monitor inbox |
| **Phone number** | Optional | Leave blank if no support phone |
| **Website** | Firebase landing URL (`legal_urls.websiteUrl`) or omit | Must load over HTTPS if provided |
| **External marketing** | **Advertise my app outside of Google Play** checkbox | **On** = Google may promote listing on Search/YouTube etc.; **Off** = Play Store only. Changes may take **up to 60 days**. Either choice is valid for publishing. |

**Rule:** Store settings email and website should match `lib/config/legal_urls.dart` and privacy policy contact block.

---

## Part 3 — App content (Policy and programs → App content)

Complete each row in the Play Console **App content** checklist.

### 3.1 Privacy policy

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Privacy policy URL | Public HTTPS page; same URL as in app | `https://dukaan-dhoondho.web.app/privacy` |

**Related URLs (not always a separate Console field but must exist):**
- Terms: `https://dukaan-dhoondho.web.app/terms`
- Account deletion: `https://dukaan-dhoondho.web.app/delete`

---

### 3.2 App access

Google asks whether reviewers need credentials to use the app.

| Scenario | Answer |
|----------|--------|
| App works without login for core features | Often **All functionality available without special access** |
| Login required for everything | **All or some functionality restricted** → provide test account |

**Dukaan Dhoondo:** Sign-in required for markets/shops (Firestore rules: `isSignedIn()`). Provide a **demo test account** for Google reviewers:

- Create a dedicated test email/password in Firebase Auth.
- In Console: **App access** → restricted → add instructions + username/password.

**Template for restricted access instructions:**

```
Sign in with the test account below. After sign-in, browse Home → any market → any shop to see products. Cart and inquiry flows are under the Cart tab.
Test email: [YOUR_TEST_EMAIL]
Test password: [YOUR_TEST_PASSWORD]
```

---

### 3.3 Ads

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Does your app contain ads? | Search codebase for ad SDKs | **No** (no AdMob / ads packages) |

If **Yes** elsewhere: declare ad format, whether ads are personalized, and complete **Families** rules if targeting children.

---

### 3.4 Content ratings (IARC questionnaire)

Complete the full questionnaire. **Path:** App content → Content ratings.

#### IARC flow overview (3 steps)

1. **Category** — contact email + app type (App / Game / Social / All Other)
2. **Questionnaire** — all sections below
3. **Summary** — review generated ratings → Submit

#### Step 1 — Category (first screen)

| Field | How to decide (any app) |
|-------|-------------------------|
| **Email address** | Valid support email you monitor (same as store listing) |
| **App or game** | Shopping/discovery/utility → **App** |
| **Social or Communication** | Only if primary purpose is chat/meeting people |
| **All Other App Types** | Marketplace, shopping, lifestyle, tools — **most Flutter utility apps** |

Pick **one** type that best matches. Shopping/discovery apps → **App** or **All Other App Types**, not Game or Social.

#### Step 2 — Questionnaire sections (complete in order)

Use this table for **any** shopping/discovery Flutter app; override per codebase.

| Section | Question (simplified) | Typical answer | How to decide |
|---------|----------------------|----------------|---------------|
| **Downloaded App** | Violence/sex/language **in the APK itself**? | **No** | Unless bundled mature content |
| **User Content Sharing** | Users exchange content with **each other** (chat, posts, images)? | **No** | Cart/inquiries to backend ≠ user-to-user sharing |
| **Online Content** | Content loaded after install (Firestore, API, web)? | **Yes** | If markets/products load from internet |
| **Violence** | App contains violent material? | **No** | Typical shopping app |
| **Sexuality** | Sexual content or nudity? | **No** | |
| **Language** | Offensive/profane language? | **No** | |
| **Age-restricted products** | Focus on cigarettes, alcohol, firearms, gambling? | **No** | |
| **Miscellaneous — location with users** | Share **precise location with other users**? | **No** | City filter on device ≠ sharing GPS with people |
| **Miscellaneous — digital goods** | In-app purchase of digital goods? | **No** | Unless Play Billing / checkout exists |
| **Miscellaneous — cash/crypto/NFT** | Rewards, crypto, NFTs? | **No** | |
| **Web browser or search engine** | App is primarily a browser/search engine? | **No** | In-app product search ≠ search engine |
| **Primarily news or educational** | Primary purpose is news or education? | **No** | |

**Critical distinction:** **Collecting location** for nearby markets (Data safety) is separate from **sharing location with other users** (Content ratings) → usually **No** for the latter.

#### Step 3 — Summary

Review country ratings → Submit. Typical shopping app: **Everyone** or similar.

#### Online content (Dukaan Dhoondo detail)

**Question:** Does the app feature or promote content that isn't part of the initial download but can be accessed from the app? (movies, product listings, news, AI content, etc.)

| How to decide | Dukaan Dhoondo |
|---------------|----------------|
| **Yes** if app loads markets, shops, products, or media from internet/Firestore/API | **Yes** |
| **No** only if everything is bundled offline in the APK | No |

**Follow-ups (typical for Dukaan Dhoondo):**

| Follow-up | Answer | Reason |
|-----------|--------|--------|
| User-generated content? | **No** | Catalog is curated; no social feed |
| Content moderated? | **Yes** | Admin-controlled catalog |
| Violence / sexual / drugs / gambling? | **No** | Shopping discovery app |
| AI-generated content? | **No** | Not applicable |

**Note:** Product listings are in `lib/data/static_catalog.dart` (bundled), but markets/shops still load from Firestore — still answer **Yes** for online content.

#### Miscellaneous (all from chat)

| Question | Dukaan Dhoondo |
|----------|----------------|
| Share user's **precise location with other users**? | **No** (location used on-device for city only) |
| Allow users to **purchase digital goods**? | **No** (no in-app checkout) |
| Cash rewards / gift cards / crypto / NFTs? | **No** |
| **Web browser or search engine**? | **No** (shopping app; in-app search ≠ search engine) |
| **Primarily news or educational**? | **No** |

**Expected rating:** Everyone or similar (no sensitive content).

---

### 3.5 Target audience and content

**Question:** What are the target age groups?

#### Generic decision tree (any app)

| Privacy policy / app design | Select these age groups |
|----------------------------|-------------------------|
| Policy says **13+**, general app, email accounts, no child-focused UI | **13–15**, **16–17**, **18 and over** |
| Adults-only content or policy says **18+** only | **18 and over only** |
| Designed for children under 13 | Child buckets (5 and under, 6–8, 9–12) + **Families policy** |

**Do NOT** select child age groups unless the app is truly designed for children. Account + email + location apps usually avoid child buckets.

**Follow-up:** “Is your app designed for children?” → **No** for typical marketplace/discovery apps.

#### Dukaan Dhoondo example

| How to decide | Dukaan Dhoondo |
|---------------|----------------|
| Apps with accounts, email, optional location — avoid child buckets | **18 and over only** |
| Do NOT select 5 and under, 6–8, 9–12 unless truly designed for children | Leave child boxes unchecked |

Selecting child age groups triggers **Families policy** and stricter data/ads rules.

---

### 3.6 News apps

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Is this a news app? | Primary purpose is news/current events | **No** |

---

### 3.7 Data safety

**Path:** App content → Data safety (5 steps)

#### Step 1 — Overview

Confirm you will disclose data collection accurately.

#### Step 2 — Data collection and security

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Collect or share required user data types? | Email account, profile, cart, location, diagnostics? | **Yes** |
| All data encrypted in transit? | Firebase uses HTTPS/TLS | **Yes** |
| Account creation methods | Check auth screens | **Username and password** only (email + password via Firebase Auth) |

**Do NOT select:** OAuth (unless Google/Apple sign-in added), "My app does not allow users to create an account".

**Skip:** Independent security review, UPI Payments verified — not applicable.

#### Account deletion fields (Data safety form)

| Question | How to decide (any app) |
|----------|-------------------------|
| **Account deletion URL** | Public HTTPS page naming the app, with in-app deletion steps + email fallback |
| **Partial deletion without deleting account?** | **No** unless app lets users delete specific data while keeping account |

**Account deletion URL patterns (read codebase — do not assume):**

| Pattern | Example path | When used |
|---------|--------------|-----------|
| Dedicated deletion page | `/delete` | `legal_urls` → delete URL; `web_docs/delete/` |
| Support page with deletion section | `/support` | `legal_urls.supportPage`; `web_docs/support/` |

Always use the URL from `lib/config/legal_urls.dart` that Play Console and the app actually open.

#### Step 3 — Data types (declare collected data)

**Generic checklist (any Firebase auth + marketplace app):**

| Data type | Check when… |
|-----------|-------------|
| **Name** | Stored in Firestore profile or Firebase Auth display name |
| **Email address** | Firebase Auth sign-up |
| **User IDs** | Firebase UID links cart/orders (under **Personal info**, not Device IDs) |
| **Approximate location** | City/market filtering with permission |
| **Precise location** | `ACCESS_FINE_LOCATION` / GPS read on device (even if only city stored) |
| **App interactions** | Browse, search, cart actions |
| **Other user-generated content** | Inquiries, orders, cart items in Firestore |
| **Device or other IDs** | Only if ads SDK or advertising ID collection |
| **Crash logs / diagnostics** | Only if Crashlytics/Analytics in `pubspec.yaml` |

**Do NOT check:** In-app search history if queries are client-side only and not stored on server.

#### Step 4 — Data usage and handling (per data type)

Generic templates — complete **Start** for each row in Console:

| Data type | Collected | Shared | Ephemeral | Required/Optional | Purpose |
|-----------|-----------|--------|-----------|-------------------|---------|
| **Name / Email / User IDs** | Yes | Yes | No | Required | App functionality, Account management |
| **Location (approx + precise)** | Yes | No | Yes (if GPS not stored on server) | Optional | App functionality |
| **App interactions / UGC** | Yes | Yes | No | Required | App functionality |

**Shared = Yes** for Firebase/Google as **service provider** (not sold to third parties). **Shared = No** for location if coordinates stay on device and are not sent to your backend.

For each type: **Not sold**, **Not used for advertising** unless true.

Typical declarations for Dukaan Dhoondo:

| Data type | Collected? | Shared? | Purpose | Required/Optional |
|-----------|------------|---------|---------|-------------------|
| **Email address** | Yes | No | Account / App functionality | Required for account |
| **Name** | Yes | No | Account / App functionality | Required |
| **Approximate location** | Yes (if city detection enabled) | No | App functionality | Optional (user grants permission) |
| **Precise location** | Maybe (GPS read on device) | No | App functionality | Optional |
| **App interactions** (cart, inquiries) | Yes | No | App functionality | Required for features |
| **Crash logs / diagnostics** | Only if Crashlytics enabled | No | Analytics | Optional (if user opts in) |

**Rules:**
- **Collected** = transmitted off device or stored by app/backend.
- **Not sold** for all types.
- **Account deletion available** — link: `https://dukaan-dhoondho.web.app/delete`

#### Step 4 — Data usage and handling

For each type: purpose = **App functionality**; no advertising/selling unless you actually do.

#### Step 5 — Preview

Review the public Data safety card before submitting.

---

### 3.8 Government apps

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Is this an official government app? | Published by government entity | **No** |

---

### 3.9 Financial features

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Banking, loans, crypto wallet, money transfer, etc.? | Any payment processing in app | **No** — discovery/inquiry only; no checkout |
| Reference prices shown | Display only ≠ financial feature | Still **No** for financial features declaration |

If your other app processes payments, complete the financial features form honestly.

---

### 3.10 Health apps

| Question | How to decide | Dukaan Dhoondo |
|----------|---------------|----------------|
| Medical device, health records, fitness tracking as primary purpose? | | **No** |

Human health apps require extra declarations (FDA, medical disclaimers, etc.).

---

### 3.11 Other App content items (checklist)

Verify these in Console — complete if shown for your app:

| Item | Dukaan Dhoondo guidance |
|------|-------------------------|
| **COVID-19 contact tracing / status** | No — skip if N/A |
| **Teacher Approved** | No — not an educational app for children |
| **Advertising ID** | Declare if using ads or certain analytics; **No ads** → typically N/A |
| **Sensitive app permissions** | Location — declare justification in listing/description if prompted |

---

## Part 4 — Release (Test and release)

Not part of store listing Q&A but required to publish:

| Step | Action |
|------|--------|
| Upload AAB | `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab` |
| Release track | **Internal testing** first → Closed → Production |
| Version | Match `pubspec.yaml` version |
| Signing | Release keystore configured in `key.properties` |

### Part 4 addendum — Release signing (any Flutter app)

| Issue | Cause | Fix |
|-------|-------|-----|
| **"Signed in debug mode"** on upload | No `android/key.properties` or missing `.jks` | Create per-app upload keystore; add `key.properties`; rebuild AAB |
| Wrong package signing | `applicationId` mismatch | Must match Play Console package name |

**Per-project keystore (recommended):**

- Use a **unique** `.jks` per app project (do not reuse across apps).
- Copy `android/key.properties.example` → `android/key.properties` (gitignored).
- `storeFile` in properties = **filename only** (resolved as `android/app/<storeFile>`).
- Back up `.jks` + passwords outside the repo.

**Verify before upload:**

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

You should **not** see `CN=Android Debug` in the certificate.

**After first successful upload (Play App Signing):**

1. Play Console → **App integrity** → copy **App signing key** SHA-1 and SHA-256.
2. Firebase Console → Project settings → Android app → add those fingerprints.
3. Keeps Firebase Auth / Google services working in release builds.

### Part 4 addendum — Legal pages hosting (Firebase)

If privacy/terms/support pages live in `web_docs/`:

```bash
firebase login
firebase deploy --only hosting --project YOUR_PROJECT_ID
```

Ensure `firebase.json` routes include `/privacy`, `/terms`, `/support` (or `/delete`). URLs in Play Console must match `lib/config/legal_urls.dart` exactly.

**Common issue:** Firebase CLI logged into wrong Google account → deploy fails or wrong project. Use the account that owns the Firebase project.

**Avoid dead URLs:** Do not use old Surge or expired hosts in Play Console if the app uses Firebase (`*.web.app`).

---

## Part 5 — Dukaan Dhoondo quick reference card

Copy-paste values for this app:

| Field | Value |
|-------|-------|
| App name | Dukaan Dhoondo |
| Package name | `com.dukaandhoondo.app` |
| Category | Shopping |
| Free or paid | Free |
| App or game | App |
| Default language | English (United States) |
| Privacy policy | https://dukaan-dhoondho.web.app/privacy |
| Terms | https://dukaan-dhoondho.web.app/terms |
| Account deletion | https://dukaan-dhoondho.web.app/delete |
| Support email | shahabudinghori804@gmail.com |
| Target age | 18 and over only |
| Ads | No |
| News app | No |
| Government app | No |
| Financial features | No |
| Health app | No |
| Online content (IARC) | Yes |
| Location shared with users | No |
| Digital goods purchases | No |
| Data collected | Yes |
| Encrypted in transit | Yes |
| Account creation | Username and password |
| Content rating | Everyone (typical) |

---

## Part 6 — Template for a NEW app (fill in blanks)

When the other agent analyzes a new project, output this table filled in:

| Field | [New App] value |
|-------|-----------------|
| App name | |
| Package name | |
| Default language | |
| App or game | |
| Free or paid | |
| Category | |
| Tags (Store settings) | |
| Privacy policy URL | |
| Terms URL | |
| Account deletion URL | |
| Support page URL | |
| Website URL | |
| Support email | |
| Phone (Store settings) | |
| External marketing (On/Off) | |
| Short description (≤80 chars) | |
| Full description | |
| Test account email (if login required) | |
| Test account password | |
| App access restricted? (Yes/No) | |
| Target age groups | |
| Contains ads? | |
| News app? | |
| Government app? | |
| Financial features? | |
| Health app? | |
| IARC — Downloaded App mature content? | |
| IARC — User content sharing? | |
| IARC — Online content? | |
| IARC — Violence / Sexuality / Language? | |
| IARC — Age-restricted products focus? | |
| IARC — Location shared with users? | |
| IARC — Digital goods / crypto / NFT? | |
| User-generated content (social)? | |
| Location collected? | |
| Payments / financial features? | |
| Data safety — collects data? | |
| Data safety — encrypted in transit? | |
| Data safety — account creation method | |
| Data safety — partial deletion without account? | |
| Data types declared (list) | |
| Per-type Collected/Shared (summary) | |
| Account deletion URL (Data safety field) | |
| Release keystore configured? | |
| Legal pages deployed and live? | |
| Firebase SHA added after first upload? | |

---

## Part 7 — Common mistakes to avoid

1. **Package name mismatch** — Gradle `applicationId` must equal Play Console package name.
2. **Privacy policy URL broken** — must load in browser without login.
3. **Support email mismatch** — store email should match privacy policy contact.
4. **Wrong support email in listing file** — always verify `lib/config/legal_urls.dart`.
5. **Saying "No" to online content** for apps that load Firestore/API catalogs.
6. **Selecting child age groups** for apps with email accounts and location.
7. **Claiming "No data collected"** when using Firebase Auth + Firestore profile/cart.
8. **Publishing near-identical apps** — see `docs/VARIANT_PLAYBOOK.md` (unique listing, screenshots, privacy URL per app).
9. **Dead privacy URL in Play Console** — old Surge/expired host while app uses Firebase (`legal_urls.dart` is source of truth).
10. **"Location shared with users" = Yes** when app only detects city locally — Content ratings wants **No** for that question.
11. **Uploading debug-signed AAB** — missing `android/key.properties` causes Play rejection.
12. **Play privacy URL ≠ in-app URL** — must match `lib/config/legal_urls.dart` exactly.
13. **Firebase deploy fails** — CLI logged into wrong Google account vs Firebase project owner.
14. **User IDs vs Device IDs** — Firebase UID goes under Personal info → User IDs, not Device or other IDs.
15. **Personal info "Shared"** — declare **Yes** for Firebase as service provider (not the same as selling data).

---

## Part 8 — Optional: catalog / products note (Dukaan Dhoondo)

- **Markets & shops:** loaded from Firestore (requires sign-in).
- **Products:** bundled in `lib/data/static_catalog.dart` with static HTTPS image URLs (Unsplash) — **no Firestore seed required** for products to appear.
- **Images:** not in Firebase Storage; URLs in code/Firestore point to Unsplash or Firebase Hosting (`/media/shops`, `/media/markets`).

This does **not** change Play Console answers much — still declare online content (markets/shops from Firestore) and internet requirement in description.

---

## Document maintenance

- **Source of truth for URLs/email:** `lib/config/legal_urls.dart`
- **Listing copy draft:** `store/play-store-listing.md` (verify email before use)
- **Variant / multi-app warnings:** `docs/VARIANT_PLAYBOOK.md` — **Note:** this file is referenced in Part 7 but may not exist in every repo; multi-app guidance is covered in Part 7 mistakes #8 until that file is added.

When you add Google Sign-In, ads, payments, or health features to any app, re-run through **Part 3** and update Data safety and Content ratings.

---

## Appendix A — Complete Play Console checklist (screenshot-free)

Use this ordered list so **no Play Console section is missed** in one agent response.

### A1 — Create app

- [ ] App name (≤30 chars)
- [ ] Default language (usually English United States)
- [ ] App or game → **App** (unless game)
- [ ] Free or paid
- [ ] Package name (= Gradle `applicationId`; Check availability)
- [ ] Declarations: Developer Program Policies + US export laws

### A2 — Main store listing

- [ ] Short description (≤80 chars)
- [ ] Full description
- [ ] App icon 512×512
- [ ] Feature graphic 1024×500
- [ ] Phone screenshots (min 2)
- [ ] App category
- [ ] Privacy policy URL (HTTPS, live)
- [ ] Store listing contact email

### A3 — Store settings

- [ ] App category + tags
- [ ] Email, phone (optional), website
- [ ] External marketing preference

### A4 — App content

- [ ] **Privacy policy** URL
- [ ] **App access** — restricted? → test account + instructions if login required
- [ ] **Ads** — Yes/No
- [ ] **Content ratings (IARC)** — Category email + full questionnaire + Summary submit
- [ ] **Target audience** — age groups + follow-ups
- [ ] **News app** — Yes/No
- [ ] **Data safety** — all 5 steps (overview, collection/security, data types, usage/handling, preview)
- [ ] **Government apps** — Yes/No
- [ ] **Financial features** — list or "My app doesn't provide any financial features"
- [ ] **Health apps** — Yes/No
- [ ] Other items if shown (COVID-19, Teacher Approved, Advertising ID, sensitive permissions)

### A5 — Release

- [ ] Release keystore + `key.properties` configured
- [ ] `flutter build appbundle --release` — not debug-signed
- [ ] Upload AAB to Internal testing first
- [ ] Legal pages deployed (`firebase deploy --only hosting` if using Firebase)
- [ ] Firebase SHA fingerprints after first upload (if using Firebase Auth)

### A6 — Agent output format

For each checklist item above, output: **Section | Answer | Reason (from code) | Copy-paste value**.

---
