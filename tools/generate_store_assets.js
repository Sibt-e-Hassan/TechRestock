/**
 * Generates Play Store listing assets from ../brand.config.json into tools/playstore/:
 *   - icon_512.png        (512x512 hi-res icon, required)
 *   - feature_graphic.png (1024x500 feature graphic, required)
 * Run: node generate_store_assets.js
 */
const sharp = require("sharp");
const fs = require("fs");
const path = require("path");
const cfg = require(path.join(__dirname, "..", "brand.config.json"));

const { gradientStart, gradientMid, gradientEnd } = cfg.palette;
const NAME = cfg.displayName;
const TAGLINE = cfg.tagline;
const OUT = path.join(__dirname, "playstore");
fs.mkdirSync(OUT, { recursive: true });

const GRAD = (id) => `
  <linearGradient id="${id}" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="${gradientStart}"/>
    <stop offset="0.5" stop-color="${gradientMid}"/>
    <stop offset="1" stop-color="${gradientEnd}"/>
  </linearGradient>`;

function mark(box, k) {
  const c = box / 2, s = box / 1024;
  const base = [
    { x: 400, y: 410, r: 120 },
    { x: 700, y: 452, r: 94 },
    { x: 486, y: 700, r: 104 },
  ];
  const t = (p) => ({ x: c + (p.x * s - c) * k, y: c + (p.y * s - c) * k, r: p.r * s * k });
  const [a, b, d] = base.map(t);
  const lw = 56 * s * k;
  return `
    <g stroke="#fff" stroke-linecap="round" stroke-width="${lw}" opacity="0.85">
      <line x1="${a.x}" y1="${a.y}" x2="${b.x}" y2="${b.y}"/>
      <line x1="${a.x}" y1="${a.y}" x2="${d.x}" y2="${d.y}"/>
    </g>
    <g fill="#fff">
      <circle cx="${a.x}" cy="${a.y}" r="${a.r}"/>
      <circle cx="${b.x}" cy="${b.y}" r="${b.r}" opacity="0.9"/>
      <circle cx="${d.x}" cy="${d.y}" r="${d.r}" opacity="0.96"/>
    </g>`;
}

const icon512 = `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>${GRAD("g")}</defs><rect width="512" height="512" fill="url(#g)"/>${mark(512, 1.0)}</svg>`;

// Feature graphic: mark on the left, name (up to two words on two lines) + tagline on the right.
const words = NAME.trim().split(/\s+/);
const nameLines = words.length >= 2
  ? [words[0], words.slice(1).join(" ")]
  : [NAME];
const nameSvg = nameLines
  .map((line, i) => `<text x="360" y="${238 + i * 92}" font-family="${cfg.font}, Arial, sans-serif" font-size="78" font-weight="700" fill="#fff" letter-spacing="-1">${line}</text>`)
  .join("");
const tagY = 238 + nameLines.length * 92 + 8;

const feature = `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="500" viewBox="0 0 1024 500">
  <defs>${GRAD("g")}</defs>
  <rect width="1024" height="500" fill="url(#g)"/>
  <g transform="translate(150,250) scale(0.34)"><g transform="translate(-512,-512)">${mark(1024, 1.0)}</g></g>
  ${nameSvg}
  <text x="365" y="${tagY}" font-family="${cfg.font}, Arial, sans-serif" font-size="30" font-weight="400" fill="#fff" opacity="0.9">${TAGLINE}</text>
</svg>`;

async function main() {
  await sharp(Buffer.from(icon512)).png().toFile(path.join(OUT, "icon_512.png"));
  await sharp(Buffer.from(feature)).flatten({ background: gradientStart }).png().toFile(path.join(OUT, "feature_graphic.png"));
  console.log(`Wrote tools/playstore/icon_512.png + feature_graphic.png for "${NAME}".`);
}
main().catch((e) => { console.error(e); process.exit(1); });
