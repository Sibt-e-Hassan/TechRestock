/**
 * Generates Play Store listing assets from ../brand.config.json into tools/playstore/
 * and store/:
 *   - icon_512.png        (512x512 hi-res icon, required)
 *   - feature_graphic.png (1024x500 feature graphic, required)
 * Run: node generate_store_assets.js
 */
const sharp = require("sharp");
const fs = require("fs");
const path = require("path");
const cfg = require(path.join(__dirname, "..", "brand.config.json"));

const ROOT = path.join(__dirname, "..");
const IMG = path.join(ROOT, "assets", "images");
const STORE = path.join(ROOT, "store");
const OUT = path.join(__dirname, "playstore");

const { gradientStart, gradientMid, gradientEnd } = cfg.palette;
const NAME = cfg.displayName;
const TAGLINE = cfg.tagline;

fs.mkdirSync(OUT, { recursive: true });
fs.mkdirSync(STORE, { recursive: true });

const GRAD = (id) => `
  <linearGradient id="${id}" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="${gradientStart}"/>
    <stop offset="0.5" stop-color="${gradientMid}"/>
    <stop offset="1" stop-color="${gradientEnd}"/>
  </linearGradient>`;

async function loadMarkPng(size) {
  const source = path.join(IMG, "logo_mark_source.png");
  const fallback = path.join(IMG, "app_icon_foreground.png");
  const input = fs.existsSync(source) ? source : fallback;
  return sharp(input)
    .resize(size, size, {
      fit: "contain",
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer();
}

async function icon512Svg() {
  const markB64 = (await loadMarkPng(360)).toString("base64");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>${GRAD("g")}</defs>
  <rect width="512" height="512" fill="url(#g)"/>
  <image href="data:image/png;base64,${markB64}" x="76" y="76" width="360" height="360"/>
</svg>`;
}

async function featureSvg() {
  const markB64 = (await loadMarkPng(300)).toString("base64");
  const words = NAME.trim().split(/\s+/);
  const nameLines = words.length >= 2 ? [words[0], words.slice(1).join(" ")] : [NAME];
  const nameSvg = nameLines
    .map(
      (line, i) =>
        `<text x="360" y="${238 + i * 92}" font-family="${cfg.font}, Arial, sans-serif" font-size="78" font-weight="700" fill="#fff" letter-spacing="-1">${line}</text>`
    )
    .join("");
  const tagY = 238 + nameLines.length * 92 + 8;

  return `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="500" viewBox="0 0 1024 500">
  <defs>${GRAD("g")}</defs>
  <rect width="1024" height="500" fill="url(#g)"/>
  <image href="data:image/png;base64,${markB64}" x="70" y="100" width="300" height="300"/>
  ${nameSvg}
  <text x="365" y="${tagY}" font-family="${cfg.font}, Arial, sans-serif" font-size="30" font-weight="400" fill="#fff" opacity="0.9">${TAGLINE}</text>
</svg>`;
}

async function main() {
  const iconSvg = await icon512Svg();
  const feature = await featureSvg();

  const iconPath = path.join(OUT, "icon_512.png");
  const featurePath = path.join(OUT, "feature_graphic.png");
  const storeFeaturePath = path.join(STORE, "feature_graphic.png");
  const storeIconPath = path.join(STORE, "icon_512.png");

  await sharp(Buffer.from(iconSvg)).png().toFile(iconPath);
  await sharp(Buffer.from(feature))
    .flatten({ background: gradientStart })
    .png()
    .toFile(featurePath);

  await fs.promises.copyFile(iconPath, storeIconPath);
  await fs.promises.copyFile(featurePath, storeFeaturePath);

  // Refresh preview JPG used in assets/images.
  await sharp(featurePath)
    .jpeg({ quality: 92 })
    .toFile(path.join(IMG, "feature_graphic.jpg"));

  console.log(`Wrote tools/playstore/icon_512.png + feature_graphic.png for "${NAME}".`);
  console.log(`Synced store/icon_512.png + store/feature_graphic.png`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
