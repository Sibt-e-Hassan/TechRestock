/**
 * rebrand.js — mechanical rebrand of a FRESH base copy, driven by
 * ../brand.config.json. Safe to run once per new variant.
 *
 * Does:
 *   1. Replaces the old app name(s) with displayName in user-facing files.
 *   2. Renames the Android package (applicationId + namespace).
 *   3. Moves MainActivity.kt into the new package.
 *
 * Does NOT touch: the Dart package name (`shop_pandaa`) / imports, Firebase
 * config, colors, or assets — those are handled by the playbook + other tools.
 *
 * Run from tools/:  node rebrand.js
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const cfg = require(path.join(ROOT, "brand.config.json"));

const displayName = cfg.displayName;
const newPkg = cfg.packageId;
const fromNames = [...cfg.rename.fromNames].sort((a, b) => b.length - a.length); // longest first
const NAME_EXT = new Set([".dart", ".xml", ".plist", ".html", ".json"]);

let filesChanged = 0;

// ---------- 1. app-name replacement ----------
function replaceNamesInFile(file) {
  if (!NAME_EXT.has(path.extname(file))) return;
  if (path.resolve(file) === path.join(ROOT, "brand.config.json")) return;
  let text = fs.readFileSync(file, "utf8");
  const before = text;
  for (const from of fromNames) {
    text = text.split(from).join(displayName);
  }
  if (text !== before) {
    fs.writeFileSync(file, text);
    filesChanged++;
    console.log("  name:", path.relative(ROOT, file));
  }
}

function walk(dir, fn) {
  if (!fs.existsSync(dir)) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(p, fn);
    else fn(p);
  }
}

console.log(`Renaming app to "${displayName}" ...`);
["lib", "test", "web"].forEach((d) => walk(path.join(ROOT, d), replaceNamesInFile));
[
  path.join(ROOT, "android/app/src/main/AndroidManifest.xml"),
  path.join(ROOT, "ios/Runner/Info.plist"),
].forEach((f) => fs.existsSync(f) && replaceNamesInFile(f));

// ---------- 2. Android package id ----------
console.log(`Setting Android package to "${newPkg}" ...`);
const gradle = path.join(ROOT, "android/app/build.gradle.kts");
let g = fs.readFileSync(gradle, "utf8");
g = g.replace(/applicationId\s*=\s*"[^"]*"/, `applicationId = "${newPkg}"`);
g = g.replace(/namespace\s*=\s*"[^"]*"/, `namespace = "${newPkg}"`);
fs.writeFileSync(gradle, g);
console.log("  gradle: applicationId + namespace");

// ---------- 3. MainActivity into new package ----------
const kotlinRoot = path.join(ROOT, "android/app/src/main/kotlin");
fs.rmSync(kotlinRoot, { recursive: true, force: true });
const pkgDir = path.join(kotlinRoot, ...newPkg.split("."));
fs.mkdirSync(pkgDir, { recursive: true });
fs.writeFileSync(
  path.join(pkgDir, "MainActivity.kt"),
  `package ${newPkg}\n\nimport io.flutter.embedding.android.FlutterActivity\n\nclass MainActivity : FlutterActivity()\n`
);
console.log("  kotlin: MainActivity ->", newPkg);

console.log(`\nDone. ${filesChanged} file(s) renamed.\n`);
console.log("NEXT (manual, see docs/VARIANT_PLAYBOOK.md):");
console.log("  1. Edit lib/theme/app_colors.dart + app_theme.dart (palette + font).");
console.log("  2. node generate_icon.js  &&  flutter_launcher_icons  &&  native_splash");
console.log(`  3. flutterfire configure --project=${cfg.firebaseProjectId} --android-package-name=${newPkg} --platforms=android,ios,web --yes`);
console.log("  4. firebase deploy --only firestore  (rules + indexes)");
console.log("  5. node seed_catalog.js  (needs tools/service-account.json)");
console.log("  6. flutter clean && flutter build appbundle --release");
