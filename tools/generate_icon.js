/**
 * Generates launcher-icon assets from the palette in ../brand.config.json
 * (gradient + connection-node mark). Run: node generate_icon.js
 * Outputs into ../assets/images/. Then run flutter_launcher_icons + native_splash.
 *
 * NOTE: ThokBazaar uses the box+arrow mark instead — run make_icons_from_source.js.
 */
const sharp = require("sharp");
const path = require("path");
const cfg = require(path.join(__dirname, "..", "brand.config.json"));

const { gradientStart, gradientMid, gradientEnd } = cfg.palette;
const OUT = path.join(__dirname, "..", "assets", "images");
const S = 1024;

const GRAD = `
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0"   stop-color="${gradientStart}"/>
      <stop offset="0.5" stop-color="${gradientMid}"/>
      <stop offset="1"   stop-color="${gradientEnd}"/>
    </linearGradient>
  </defs>`;

// Connection-node mark, centred, scaled by `k` about the canvas centre.
function mark(k) {
  const n = [
    { x: 400, y: 410, r: 120 },
    { x: 700, y: 452, r: 94 },
    { x: 486, y: 700, r: 104 },
  ];
  const cx = 512, cy = 512;
  const t = (p) => ({ x: cx + (p.x - cx) * k, y: cy + (p.y - cy) * k, r: p.r * k });
  const [a, b, c] = n.map(t);
  const lw = 56 * k;
  return `
    <g stroke="#ffffff" stroke-linecap="round" stroke-width="${lw}" opacity="0.85">
      <line x1="${a.x}" y1="${a.y}" x2="${b.x}" y2="${b.y}"/>
      <line x1="${a.x}" y1="${a.y}" x2="${c.x}" y2="${c.y}"/>
    </g>
    <g fill="#ffffff">
      <circle cx="${a.x}" cy="${a.y}" r="${a.r}"/>
      <circle cx="${b.x}" cy="${b.y}" r="${b.r}" opacity="0.9"/>
      <circle cx="${c.x}" cy="${c.y}" r="${c.r}" opacity="0.96"/>
    </g>`;
}

const fullSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${GRAD}<rect width="${S}" height="${S}" fill="url(#g)"/>${mark(1.0)}</svg>`;

const foregroundSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${mark(0.62)}</svg>`; // transparent bg, mark inside adaptive safe zone

const backgroundSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${GRAD}<rect width="${S}" height="${S}" fill="url(#g)"/></svg>`;

async function render(svg, file) {
  await sharp(Buffer.from(svg)).png().toFile(path.join(OUT, file));
  console.log("wrote", file);
}

(async () => {
  await render(fullSvg, "app_icon.png");
  await render(foregroundSvg, "app_icon_foreground.png");
  await render(backgroundSvg, "app_icon_background.png");
  console.log(`Done — icons use ${gradientStart} -> ${gradientEnd}.`);
})().catch((e) => { console.error(e); process.exit(1); });
