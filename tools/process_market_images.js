/**
 * Resizes/compresses downloaded market + shop images and writes them into
 * web_docs/media/{markets,shops}/ for Firebase Hosting.
 * Run: node process_market_images.js
 */
const sharp = require("sharp");
const fs = require("fs");
const path = require("path");

const SRC = "C:/Users/HF/AppData/Local/Temp/imgs";
const OUT_MARKETS = path.join(__dirname, "..", "web_docs", "media", "markets");
const OUT_SHOPS = path.join(__dirname, "..", "web_docs", "media", "shops");

fs.mkdirSync(OUT_MARKETS, { recursive: true });
fs.mkdirSync(OUT_SHOPS, { recursive: true });

const heroes = [
  ["anarkali_hero.jpg", "anarkali.jpg"],
  ["centaurus_hero.jpg", "centaurus.jpg"],
  ["saddar_hero.jpg", "saddar.jpg"],
  ["hussain/hero_candidate1.jpg", "hussain.jpg"],
];

async function processOne(srcPath, outPath, width) {
  await sharp(srcPath)
    .rotate() // respect EXIF orientation
    .resize({ width, withoutEnlargement: true })
    .jpeg({ quality: 78, mozjpeg: true })
    .toFile(outPath);
  const { size } = fs.statSync(outPath);
  return size;
}

async function main() {
  let total = 0;

  for (const [src, out] of heroes) {
    const size = await processOne(path.join(SRC, src), path.join(OUT_MARKETS, out), 1400);
    total += size;
    console.log("market:", out, (size / 1024).toFixed(0) + "KB");
  }

  const shopsDir = path.join(SRC, "shops");
  const files = fs.readdirSync(shopsDir).filter((f) => f.endsWith(".jpg"));
  for (const f of files) {
    const size = await processOne(path.join(shopsDir, f), path.join(OUT_SHOPS, f), 1000);
    total += size;
    console.log("shop:", f, (size / 1024).toFixed(0) + "KB");
  }

  console.log(`\nDone. ${heroes.length} market heroes + ${files.length} shop images.`);
  console.log(`Total size: ${(total / 1024 / 1024).toFixed(2)} MB`);
}

main().catch((e) => { console.error(e); process.exit(1); });
