const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

const REPLACEMENTS = [
  { from: 'package:tech_restock/', to: 'package:tech_restock/' },
  { from: 'com.techrestock.app', to: 'com.techrestock.app' },
  { from: 'techrestock-b2b', to: 'techrestock-b2b' },
  { from: 'techrestock', to: 'techrestock' },
  { from: 'TechRestock', to: 'TechRestock' },
  { from: 'tech_restock', to: 'tech_restock' },
  { from: 'shankhaan0001@gmail.com', to: 'shankhaan0001@gmail.com' }
];

const EXTENSIONS = new Set(['.dart', '.xml', '.plist', '.html', '.json', '.yaml', '.gradle', '.kts', '.md', '.txt', '.js']);

let modifiedCount = 0;

function processFile(filePath) {
  const ext = path.extname(filePath);
  if (!EXTENSIONS.has(ext)) return;
  if (filePath.includes('node_modules') || filePath.includes('.git') || filePath.includes('.cursor') || filePath.includes('pubspec.lock')) return;

  try {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;

    for (const r of REPLACEMENTS) {
      content = content.split(r.from).join(r.to);
    }

    if (content !== original) {
      fs.writeFileSync(filePath, content, 'utf8');
      modifiedCount++;
      console.log(`[UPDATED] ${path.relative(ROOT, filePath)}`);
    }
  } catch (e) {
    console.error(`Error reading ${filePath}:`, e.message);
  }
}

function walkDir(dirPath) {
  if (!fs.existsSync(dirPath)) return;
  const entries = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dirPath, entry.name);
    if (entry.name === '.git' || entry.name === 'node_modules' || entry.name === '.cursor') continue;
    if (entry.isDirectory()) {
      walkDir(fullPath);
    } else {
      processFile(fullPath);
    }
  }
}

console.log('--- Starting TechRestock Rebrand Script ---');

// Walk through directories
['lib', 'test', 'web', 'android', 'ios', 'store', 'tools', 'web_docs', 'docs'].forEach(dir => {
  walkDir(path.join(ROOT, dir));
});

// Process root files
['pubspec.yaml', 'README.md', 'firebase.json', '.firebaserc'].forEach(f => {
  const p = path.join(ROOT, f);
  if (fs.existsSync(p)) processFile(p);
});

// Fix Kotlin MainActivity structure
const kotlinRoot = path.join(ROOT, 'android/app/src/main/kotlin');
fs.rmSync(kotlinRoot, { recursive: true, force: true });
const newPkgDir = path.join(kotlinRoot, 'com', 'techrestock', 'app');
fs.mkdirSync(newPkgDir, { recursive: true });
fs.writeFileSync(
  path.join(newPkgDir, 'MainActivity.kt'),
  `package com.techrestock.app\n\nimport io.flutter.embedding.android.FlutterActivity\n\nclass MainActivity : FlutterActivity()\n`,
  'utf8'
);
console.log('[KOTLIN] Created MainActivity.kt in com.techrestock.app');

console.log(`\nRebrand complete. Modified ${modifiedCount} file(s).`);
