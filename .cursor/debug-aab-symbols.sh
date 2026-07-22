#!/usr/bin/env bash
# #region agent log
# Debug instrumentation: checks AAB debug-symbol stripping preconditions.
set -euo pipefail
LOG="/Users/mac/Projects/personal/ThokBazaar/.cursor/debug-1b5c77.log"
SESSION="1b5c77"
RUN_ID="${1:-pre-fix}"
TS=$(($(date +%s)*1000))
JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
AAB="/Users/mac/Projects/personal/ThokBazaar/build/app/outputs/bundle/release/app-release.aab"
APKANALYZER="/Users/mac/Library/Android/sdk/cmdline-tools/latest/bin/apkanalyzer"
GRADLE_PROPS="/Users/mac/Projects/personal/ThokBazaar/android/gradle.properties"

log_json() {
  local hyp="$1" loc="$2" msg="$3" data="$4"
  printf '{"sessionId":"%s","runId":"%s","hypothesisId":"%s","location":"%s","message":"%s","data":%s,"timestamp":%s}\n' \
    "$SESSION" "$RUN_ID" "$hyp" "$loc" "$msg" "$data" "$TS" >> "$LOG"
}

disable_symbol=$(grep -E '^android.disableSymbolProcessing=' "$GRADLE_PROPS" 2>/dev/null || true)
debug_level=$(grep -E 'debugSymbolLevel' /Users/mac/Projects/personal/ThokBazaar/android/app/build.gradle.kts 2>/dev/null || true)
log_json "A" "debug-aab-symbols.sh:gradle" "gradle symbol settings" "{\"disableSymbolProcessing\":\"${disable_symbol:-none}\",\"debugSymbolLevelLine\":\"${debug_level:-none}\"}"

if [[ -x "$APKANALYZER" ]]; then
  apka_exit=0
  apka_out=$("$APKANALYZER" files list "$AAB" 2>&1) || apka_exit=$?
  has_flutter_sym=$(echo "$apka_out" | grep -E 'libflutter\.so\.(sym|dbg)' || true)
  has_app_sym=$(echo "$apka_out" | grep -E 'libapp\.so\.(sym|dbg)' || true)
  log_json "A" "debug-aab-symbols.sh:apkanalyzer" "aab symbol file presence" "{\"aabExists\":$( [[ -f "$AAB" ]] && echo true || echo false ),\"apkanalyzerExit\":$apka_exit,\"hasLibflutterSymOrDbg\":$( [[ -n "$has_flutter_sym" ]] && echo true || echo false ),\"hasLibappSymOrDbg\":$( [[ -n "$has_app_sym" ]] && echo true || echo false )}"
else
  log_json "C" "debug-aab-symbols.sh:apkanalyzer" "apkanalyzer missing" "{\"path\":\"$APKANALYZER\"}"
fi

llvm_strip=$(ls /Users/mac/Library/Android/sdk/ndk/*/toolchains/llvm/prebuilt/*/bin/llvm-strip 2>/dev/null | head -1 || true)
log_json "D" "debug-aab-symbols.sh:ndk" "ndk llvm-strip availability" "{\"llvmStripPath\":\"${llvm_strip:-missing}\"}"
# #endregion
