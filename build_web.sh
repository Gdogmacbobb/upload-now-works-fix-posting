#!/bin/bash
# YNFNY Web Build Script
# This script ensures Material Icons are preserved during builds
# The --no-tree-shake-icons flag is REQUIRED to keep all icon glyphs

set -e

echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🌐 Building for web (preserving Material Icons)..."
flutter build web --release --no-tree-shake-icons

echo "✅ Build complete! Icons preserved."
echo "📊 MaterialIcons font bundled:"
ls -lh build/web/assets/fonts/MaterialIcons-Regular.otf 2>/dev/null || echo "⚠️ Warning: MaterialIcons font not found!"
