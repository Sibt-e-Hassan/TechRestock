# Shop Panda visual assets

## Launcher icon (required for Play Store)

Replace this placeholder with your final artwork, then regenerate icons:

| File | Size | Usage |
|------|------|--------|
| `app_icon.png` | **1024×1024** PNG | Master launcher icon (square, no rounded corners) |

```bash
dart run flutter_launcher_icons
```

## Splash screen

Uses the same `app_icon.png` centered on brand background `#A7D7D7`. Optional: add `splash_logo.png` (512×512, transparent PNG) and point `flutter_native_splash` `image` to it instead.

```bash
dart run flutter_native_splash:create
```

## Tips

- Keep important logo content inside the center **66%** safe zone (Android adaptive icon crop).
- Use a transparent PNG for adaptive foreground if you switch to separate foreground/background files later.
