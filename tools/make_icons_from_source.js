// Regenerates launcher-icon + store assets from the user-provided icon
// (assets/images/app_icon.png) and feature graphic (assets/images/feature_graphic.jpg).
// Run from tools/:  node make_icons_from_source.js
const sharp = require("sharp");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const IMG = path.join(ROOT, "assets", "images");
const STORE = path.join(ROOT, "store");
const SIZE = 1024;
// Brand purple sampled from the feature graphic's dominant colour.
const PURPLE = { r: 0x78, g: 0x58, b: 0xf8, alpha: 1 };

(async () => {
  // 1. Read source, trim the surrounding white margin down to the rounded logo.
  const trimmed = await sharp(path.join(IMG, "app_icon.png"))
    .trim({ threshold: 12 })
    .resize(SIZE, SIZE, { fit: "fill" })
    .png()
    .toBuffer();

  // 2. Rounded-rect mask removes the white corner triangles the trim leaves,
  //    leaving a clean rounded icon with transparent corners.
  const r = 200;
  const mask = Buffer.from(
    `<svg width="${SIZE}" height="${SIZE}"><rect width="${SIZE}" height="${SIZE}" rx="${r}" ry="${r}" fill="#fff"/></svg>`
  );
  const rounded = await sharp(trimmed)
    .composite([{ input: mask, blend: "dest-in" }])
    .png()
    .toBuffer();

  // 3. Full-bleed launcher icon: rounded logo on a purple square (no white).
  const fullBleed = await sharp({
    create: { width: SIZE, height: SIZE, channels: 4, background: PURPLE },
  })
    .composite([{ input: rounded }])
    .png()
    .toBuffer();
  await sharp(fullBleed).toFile(path.join(IMG, "app_icon.png"));

  // 4. Adaptive background: solid purple.
  await sharp({
    create: { width: SIZE, height: SIZE, channels: 4, background: PURPLE },
  })
    .png()
    .toFile(path.join(IMG, "app_icon_background.png"));

  // 5. Adaptive / splash foreground: the logo padded into the safe zone,
  //    on transparent (the purple background shows through the margins).
  const inner = Math.round(SIZE * 0.7);
  const fg = await sharp(rounded).resize(inner, inner).png().toBuffer();
  await sharp({
    create: { width: SIZE, height: SIZE, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } },
  })
    .composite([{ input: fg, gravity: "center" }])
    .png()
    .toFile(path.join(IMG, "app_icon_foreground.png"));

  // 6. Play Store icon (512×512).
  await sharp(fullBleed).resize(512, 512).png().toFile(path.join(STORE, "icon_512.png"));

  // 7. Play Store feature graphic: exactly 1024×500 PNG (no alpha).
  await sharp(path.join(IMG, "feature_graphic.jpg"))
    .resize(1024, 500, { fit: "cover" })
    .flatten({ background: "#ffffff" })
    .png()
    .toFile(path.join(STORE, "feature_graphic.png"));

  console.log("Generated: app_icon.png, app_icon_background.png, app_icon_foreground.png,");
  console.log("           store/icon_512.png, store/feature_graphic.png");
})();
