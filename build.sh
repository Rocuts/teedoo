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
DART_DEFINES=""
if [ -n "$OPENAI_API_KEY" ]; then
  DART_DEFINES="--dart-define=OPENAI_API_KEY=$OPENAI_API_KEY"
  echo "==> OPENAI_API_KEY injected via --dart-define"
fi
flutter build web --release --base-href / $DART_DEFINES

echo "==> Build complete! Output in build/web/"
