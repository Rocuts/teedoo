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
flutter build web --release --base-href /

echo "==> Build complete! Output in build/web/"
