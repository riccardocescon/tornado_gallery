#!/usr/bin/env bash
# Build hardened release binaries for Android (.aab) and iOS (.ipa).
#
# Usage:
#   ./scripts/build_release.sh [android|ios|all]   (default: all)
#
# Applies:
#   - Flutter Dart obfuscation   (--obfuscate)
#   - Split debug-info           (symbols stored locally, NOT shipped in binary)
#   - Android R8 minification    (configured in build.gradle.kts)
#   - Android ProGuard rules     (android/app/proguard-rules.pro)
#   - iOS symbol stripping       (configured in project.pbxproj)

set -euo pipefail

PLATFORM="${1:-all}"

# Resolve to app root (one level up from /scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$APP_ROOT"

SYMBOLS_DIR="$APP_ROOT/build/release-symbols"
mkdir -p "$SYMBOLS_DIR"

echo "==> Using symbol output: $SYMBOLS_DIR"

build_android() {
    echo ""
    echo "==> Building Android release AAB..."

    flutter build appbundle \
        --release \
        --obfuscate \
        --split-debug-info="$SYMBOLS_DIR/android"

    echo ""
    echo "[OK] Android AAB -> build/app/outputs/bundle/release/app-release.aab"
    echo "[OK] Debug symbols -> $SYMBOLS_DIR/android"
    echo ""
    echo "  IMPORTANT: upload symbol files to Play Console"
    echo "  (Release > App bundle explorer > Download symbols)"
}

build_ios() {
    echo ""
    echo "==> Building iOS release archive..."

    # Remove --no-codesign if building locally with a valid certificate
    flutter build ipa \
        --release \
        --obfuscate \
        --split-debug-info="$SYMBOLS_DIR/ios" \
        --no-codesign

    echo ""
    echo "[OK] iOS IPA -> build/ios/ipa"
    echo "[OK] Debug symbols -> $SYMBOLS_DIR/ios"
    echo ""
    echo "  IMPORTANT: upload dSYM + symbol files to App Store Connect / Crashlytics"
}

case "$PLATFORM" in
    android) build_android ;;
    ios)     build_ios     ;;
    all)     build_android; build_ios ;;
    *)
        echo "Unknown platform: $PLATFORM. Use android | ios | all"
        exit 1
        ;;
esac
