#!/bin/bash
set -e

FLUTTER_VERSION="3.41.2"
FLUTTER_DIR="$HOME/flutter-sdk"

echo "==> Installing Flutter $FLUTTER_VERSION..."
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

export PATH="$PATH:$FLUTTER_DIR/bin"

echo "==> Flutter version:"
flutter --version

echo "==> Getting dependencies..."
flutter pub get

echo "==> Building Flutter Web (release)..."
DART_DEFINES=()

if [ -n "$TEEDOO_API_BASE_URL" ]; then
  DART_DEFINES+=("--dart-define=TEEDOO_API_BASE_URL=$TEEDOO_API_BASE_URL")
  echo "==> TEEDOO_API_BASE_URL injected via --dart-define"
fi

if [ -n "$DEMO_AUTH_ENABLED" ]; then
  DART_DEFINES+=("--dart-define=DEMO_AUTH_ENABLED=$DEMO_AUTH_ENABLED")
  echo "==> DEMO_AUTH_ENABLED injected via --dart-define"
fi

flutter build web --release --base-href / "${DART_DEFINES[@]}"

echo "==> Build complete! Output in build/web/"
