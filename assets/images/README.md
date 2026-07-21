# ThokBazaar visual assets

## Source mark

| File | Usage |
|------|--------|
| `logo_mark_source.png` | White box+arrow mark on transparent background (do not delete) |

Regenerate launcher + splash PNGs from the mark and [`brand.config.json`](../../brand.config.json) palette:

```bash
cd tools
node make_icons_from_source.js
cd ..
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Play Store assets

```bash
cd tools
node generate_store_assets.js
```

Writes `tools/playstore/` and syncs `store/feature_graphic.png` + `store/icon_512.png`.

## Splash screen

Uses `app_icon_foreground.png` centered on brand navy `#1B3A57`.

## Tips

- Keep important logo content inside the center **66%** safe zone (Android adaptive icon crop).
- Palette must match `brand.config.json` and `lib/theme/app_colors.dart`.
