// Regenerates launcher-icon assets from the box+arrow mark (logo_mark_source.png)
// using the palette in ../brand.config.json. Run from tools/: node make_icons_from_source.js
// Then: dart run flutter_launcher_icons && dart run flutter_native_splash:create
const sharp = require("sharp");
const fs = require("fs");
const path = require("path");
const cfg = require(path.join(__dirname, "..", "brand.config.json"));

const ROOT = path.join(__dirname, "..");
const IMG = path.join(ROOT, "assets", "images");
const STORE = path.join(ROOT, "store");
const SIZE = 1024;
const SOURCE = path.join(IMG, "logo_mark_source.png");
const LEGACY_SOURCE = path.join(IMG, "app_icon.png");

const { gradientStart, gradientMid, gradientEnd } = cfg.palette;

function gradientSvg(w, h) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">
    <defs>
      <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
        <stop offset="0" stop-color="${gradientStart}"/>
        <stop offset="0.5" stop-color="${gradientMid}"/>
        <stop offset="1" stop-color="${gradientEnd}"/>
      </linearGradient>
    </defs>
    <rect width="${w}" height="${h}" fill="url(#g)"/>
  </svg>`;
}

async function extractWhiteMark(inputPath) {
  const { data, info } = await sharp(inputPath)
    .ensureAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true });

  const out = Buffer.from(data);
  for (let i = 0; i < out.length; i += 4) {
    const r = out[i];
    const g = out[i + 1];
    const b = out[i + 2];
    const lum = 0.299 * r + 0.587 * g + 0.114 * b;
    if (lum > 185 && r > 160 && g > 160 && b > 160) {
      out[i] = 255;
      out[i + 1] = 255;
      out[i + 2] = 255;
      out[i + 3] = 255;
    } else {
      out[i + 3] = 0;
    }
  }

  return sharp(out, { raw: { width: info.width, height: info.height, channels: 4 } })
    .trim({ threshold: 8 })
    .png()
    .toBuffer();
}

async function ensureLogoSource() {
  if (fs.existsSync(SOURCE)) {
    return sharp(SOURCE).png().toBuffer();
  }

  const extracted = await extractWhiteMark(LEGACY_SOURCE);
  await sharp(extracted).toFile(SOURCE);
  console.log("wrote logo_mark_source.png (extracted from app_icon.png)");
  return extracted;
}

(async () => {
  fs.mkdirSync(STORE, { recursive: true });
  const mark = await ensureLogoSource();

  const inner = Math.round(SIZE * 0.72);
  const markSized = await sharp(mark)
    .resize(inner, inner, {
      fit: "contain",
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer();

  const bgBuffer = await sharp(Buffer.from(gradientSvg(SIZE, SIZE))).png().toBuffer();

  const fullBleed = await sharp(bgBuffer)
    .composite([{ input: markSized, gravity: "center" }])
    .png()
    .toBuffer();

  const r = 200;
  const mask = Buffer.from(
    `<svg width="${SIZE}" height="${SIZE}"><rect width="${SIZE}" height="${SIZE}" rx="${r}" ry="${r}" fill="#fff"/></svg>`
  );
  const roundedFull = await sharp(fullBleed)
    .composite([{ input: mask, blend: "dest-in" }])
    .png()
    .toBuffer();

  await sharp(roundedFull).toFile(path.join(IMG, "app_icon.png"));
  await sharp(bgBuffer).toFile(path.join(IMG, "app_icon_background.png"));

  const fgInner = Math.round(SIZE * 0.7);
  const fgMark = await sharp(mark)
    .resize(fgInner, fgInner, {
      fit: "contain",
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer();
  await sharp({
    create: {
      width: SIZE,
      height: SIZE,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    },
  })
    .composite([{ input: fgMark, gravity: "center" }])
    .png()
    .toFile(path.join(IMG, "app_icon_foreground.png"));

  await sharp(roundedFull).resize(512, 512).png().toFile(path.join(STORE, "icon_512.png"));

  console.log("Generated: app_icon.png, app_icon_background.png, app_icon_foreground.png,");
  console.log(`           store/icon_512.png (${gradientStart} -> ${gradientEnd})`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
