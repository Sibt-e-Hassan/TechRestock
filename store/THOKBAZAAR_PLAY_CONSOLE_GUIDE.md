# ThokBazaar — Google Play Console Copy-Paste Guide

This document contains every exact answer needed to fill out the Google Play Console for ThokBazaar, keeping the exact sequence from your `PLAY_STORE_PLAYBOOK.md`.

## A1 — Create App

| Section | Answer / Action | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| App name | Text | Brand name | `ThokBazaar` |
| Default language | English (United States) - en-US | Primary audience language | `English (United States) - en-US` |
| App or game | App | Shopping and utility | `App` |
| Free or paid | Free | No upfront purchase cost | `Free` |
| Package name | Text | Matches `build.gradle.kts` | `com.thokbazaar.app` |
| Declarations | Check both boxes | Required by Google policies | (Check both boxes) |

---

## A2 — Main Store Listing

| Section | Answer / Action | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| Short description | Text (max 80 chars) | One-line value prop | `Wholesale ordering for shopkeepers — bulk rates, supplier khata & restock.` |
| Full description | Text (max 4000 chars) | Full app features | *(Copy the full contents of `store/long_description.txt` here)* |
| App icon | Upload Image | Must be 512x512 | Upload `store/icon_512.png` |
| Feature graphic | Upload Image | Must be 1024x500 | Upload `store/feature_graphic.png` |
| Phone screenshots | Upload Images | Shows app in action | Upload screenshots you took on your device |
| App category | Shopping | Best fit for wholesale | `Shopping` |
| Privacy policy URL | Text (HTTPS) | Matches legal_urls.dart | `https://thokbazaar-4a79a.web.app/privacy` |
| Store listing email | Text | Matches legal_urls.dart | `raspharmaceutical51@gmail.com` |

---

## A3 — Store Settings

| Section | Answer / Action | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| App category | Shopping | Match listing | `Shopping` |
| Tags | Shopping, B2B, Marketplace | Helps discovery | `Shopping` |
| Email address | Text | Must match privacy policy | `raspharmaceutical51@gmail.com` |
| Phone number | Leave blank | Optional | (Leave blank) |
| Website | Leave blank | Optional | (Leave blank) |
| External marketing | Check "Advertise my app outside Google Play" | Recommended for discovery | (Check the box) |

---

## A4 — App Content

### 1. Privacy Policy

| Section | Answer | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| Privacy policy URL | Text (HTTPS) | Matches legal_urls.dart | `https://thokbazaar-4a79a.web.app/privacy` |

### 2. App Access

| Section | Answer | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| App access | All or some functionality is restricted | Login is required to view catalog | `All or some functionality is restricted` |
| Instructions | Text | Reviewers need to log in | `Sign in to view wholesale products, cart, and khata features. Test email: test@thokbazaar.com Test password: password123` *(Note: create this test user in Firebase Auth first)* |

### 3. Ads

| Section | Answer | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| Contains ads? | No | No AdMob or ads SDK in pubspec | `No, my app does not contain ads` |

### 4. Content Ratings (IARC)

*Select Category: App / All Other App Types*

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Downloaded App (Violence/sex/language) | **No** | Shopping app |
| User Content Sharing | **No** | Orders to backend ≠ user sharing |
| Online Content | **Yes** | Catalog/orders sync with Firebase |
| Violence / Sexuality / Language | **No** | Not applicable |
| Age-restricted products | **No** | Not applicable |
| Miscellaneous (Share location with users) | **No** | Not a social/location sharing app |
| Miscellaneous (Digital goods/crypto/NFT) | **No** | Physical wholesale goods only |
| Primarily news/educational/browser | **No** | It is a B2B shopping app |

### 5. Target Audience

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Target age groups | **18 and over** | B2B wholesale app requiring accounts. Do not select children's age groups. |
| Designed for children | **No** | Business tool |

### 6. News App

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Is this a news app? | **No** | B2B Shopping |

### 7. Data Safety

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Collect/share required data? | **Yes** | Email, orders, app interactions |
| All data encrypted in transit? | **Yes** | Firebase uses HTTPS |
| Account creation method | **Username and password** | Firebase Auth email/password |
| Account deletion URL | `https://thokbazaar-4a79a.web.app/delete` | From legal_urls.dart |
| Partial deletion without account? | **No** | Data deletes with account |

**Data Types to Declare:**

| Data Type | Collected | Shared | Required | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Name** | Yes | No | Required | App functionality, Account management |
| **Email address** | Yes | No | Required | App functionality, Account management |
| **User IDs** | Yes | No | Required | App functionality (Firebase UID) |
| **App interactions** | Yes | No | Required | App functionality (Cart, Khata) |

*(Note: Data is not "shared" in the sense of being sold. It is only collected and sent to your Firebase database.)*

### 8. Government Apps

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Official government app? | **No** | Private business app |

### 9. Financial Features

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Financial features? | **No** | (Scroll to bottom and select "My app doesn't provide any financial features" — the app handles inquiries/credit tracking, but not actual digital payment processing). |

### 10. Health Apps

| Section | Answer | Reason |
| :--- | :--- | :--- |
| Health app? | **No** | Shopping app |

---

## A5 — Release Checklist

Before you finally submit, make sure you have done the following locally:

1. Create the test user in your Firebase Authentication (`test@thokbazaar.com` / `password123` or whatever you specified in the App Access section).
2. Grab the signed App Bundle we generated (`build/app/outputs/bundle/release/app-release.aab`) and upload it to the **Production** or **Internal Testing** track.
## A6 — Release Notes

When you upload your `.aab` file to a release track, you will be prompted to provide Release Notes for this version.

| Section | Answer | Reason | Copy-paste value |
| :--- | :--- | :--- | :--- |
| Release Notes (en-US) | Text (max 500 chars) | Summary of this version | `Initial release of ThokBazaar! Browse the wholesale catalog, view bulk pricing tiers, send order requests, and track your khata balance with suppliers.` |