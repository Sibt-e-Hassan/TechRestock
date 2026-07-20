# Shoppanda — Visual UI Mockups

Static HTML/CSS mockups only. No Flutter, JavaScript logic, APIs, or state management.

Design language based on the **Shoppanda sign-in reference** (mint-to-cream gradient, panda shop logo, Playfair Display + Inter, teal-to-navy primary buttons).

## View the designs

Open in any browser:

```
design/index.html
```

Windows:

```powershell
Start-Process "design\index.html"
```

## Structure

| Path | Purpose |
|------|---------|
| `css/design-system.css` | Tokens, gradients, logo, cards, auth layout |
| `index.html` | Gallery of 14 screens (390×844 phone frames) |

## Screens

| # | Label |
|---|--------|
| 1 | Sign in |
| 2 | Sign in · Filled |
| 3 | Sign in · Validation |
| 4 | Create account |
| 5 | Create account · Submit |
| 6 | Home · Empty |
| 7 | Home · Country focus |
| 8 | Search · Filters |
| 9 | Search · Empty |
| 10 | Profile & settings |
| 11 | Profile · Edit name |
| 12 | Profile · Delete account |
| 13 | Legal center |
| 14 | Home · Country + keyboard |

All original app fields, toggles, links, and sections from the screenshot set are preserved; only visual styling matches the reference.

## Brand tokens (reference)

| Token | Value |
|-------|--------|
| Page gradient | `#a7d7d7` → `#f9f9f7` |
| Primary button | Teal → navy horizontal gradient |
| Logo tile | Deep teal gradient + panda/shop mark |
| Brand wordmark | Playfair Display, `#0d3d40` |
| UI font | Inter |
| Card radius | 28px |
| Card shadow | `0 10px 30px rgba(0,0,0,0.05)` |
| Link / accent teal | `#2d7a7b` |
