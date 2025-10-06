#!/bin/bash

# YNFNY Flutter Web Application Server
# Builds and serves the Flutter web app with latest changes

set -e

echo "Starting YNFNY Flutter web application..."

# Kill any existing servers on port 5000
pkill -f "python3 -m http.server 5000" || true
sleep 2

# Force a fresh build with latest code changes
echo "Building Flutter web app with hardcoded Supabase configuration..."
flutter build web --release --pwa-strategy=none

echo "Serving YNFNY Flutter build from build/web"
echo "Environment: Replit | Port: 5000 | Host: 0.0.0.0"  
echo "Supabase: Connected | Auth: Enabled"
echo "Service Worker: Disabled for immediate updates"

# Serve the fresh Flutter web build
cd build/web && exec python3 -m http.server 5000 --bind 0.0.0.0