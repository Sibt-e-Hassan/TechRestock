const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

const OUT = path.join(__dirname, '..', 'assets', 'images');
const STORE = path.join(__dirname, '..', 'store');
const S = 1024;

// TechRestock Palette
const bgNavy = '#0F2537';
const bgNavyDark = '#081420';
const cyanAccent = '#00A8E8';

const GRAD = `
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0"   stop-color="${bgNavy}"/>
      <stop offset="0.6" stop-color="#14324B"/>
      <stop offset="1"   stop-color="${bgNavyDark}"/>
    </linearGradient>
    <linearGradient id="cyanG" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0"   stop-color="#00D2FF"/>
      <stop offset="1"   stop-color="${cyanAccent}"/>
    </linearGradient>
  </defs>`;

// Tech microchip / circuit gear box mark
function mark(scale = 1.0) {
  const cx = S / 2;
  const cy = S / 2;
  return `
  <g transform="translate(${cx}, ${cy}) scale(${scale}) translate(${-cx}, ${-cy})">
    <!-- Outer Shield / Box Frame -->
    <rect x="256" y="256" width="512" height="512" rx="110" ry="110" fill="none" stroke="url(#cyanG)" stroke-width="38" opacity="0.9" />
    
    <!-- Microchip / Tech Core -->
    <rect x="366" y="366" width="292" height="292" rx="44" ry="44" fill="url(#cyanG)" />
    
    <!-- Circuit Pins / Connectors -->
    <g stroke="#ffffff" stroke-width="24" stroke-linecap="round">
      <!-- Top pins -->
      <line x1="432" y1="256" x2="432" y2="366" />
      <line x1="512" y1="256" x2="512" y2="366" />
      <line x1="592" y1="256" x2="592" y2="366" />
      
      <!-- Bottom pins -->
      <line x1="432" y1="658" x2="432" y2="768" />
      <line x1="512" y1="658" x2="512" y2="768" />
      <line x1="592" y1="658" x2="592" y2="768" />
      
      <!-- Left pins -->
      <line x1="256" y1="432" x2="366" y2="432" />
      <line x1="256" y1="512" x2="366" y2="512" />
      <line x1="256" y1="592" x2="366" y2="592" />
      
      <!-- Right pins -->
      <line x1="658" y1="432" x2="768" y2="432" />
      <line x1="658" y1="512" x2="768" y2="512" />
      <line x1="658" y1="592" x2="768" y2="592" />
    </g>

    <!-- Center Arrow / Restock Lightning Symbol -->
    <path d="M 522 422 L 442 522 L 502 522 L 492 602 L 582 502 L 522 502 Z" fill="#ffffff" />
  </g>`;
}

const fullSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${GRAD}<rect width="${S}" height="${S}" fill="url(#g)"/>${mark(0.95)}</svg>`;

const foregroundSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${GRAD}${mark(0.68)}</svg>`;

const backgroundSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${GRAD}<rect width="${S}" height="${S}" fill="url(#g)"/></svg>`;

async function main() {
  if (!fs.existsSync(OUT)) fs.mkdirSync(OUT, { recursive: true });
  if (!fs.existsSync(STORE)) fs.mkdirSync(STORE, { recursive: true });

  await sharp(Buffer.from(fullSvg)).png().toFile(path.join(OUT, 'app_icon.png'));
  await sharp(Buffer.from(foregroundSvg)).png().toFile(path.join(OUT, 'app_icon_foreground.png'));
  await sharp(Buffer.from(backgroundSvg)).png().toFile(path.join(OUT, 'app_icon_background.png'));
  await sharp(Buffer.from(fullSvg)).resize(512, 512).png().toFile(path.join(STORE, 'icon_512.png'));

  console.log('Successfully generated TechRestock launcher icons.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
