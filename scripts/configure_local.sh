#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for appauth_pair in \
  'lib/firebase_options.example.dart:lib/firebase_options.dart' \
  'lib/service/firebase_service.example.dart:lib/service/firebase_service.dart' \
  'firebase.example.json:firebase.json'; do
  appauth_source="${appauth_pair%%:*}"
  appauth_target="${appauth_pair#*:}"
  if [ ! -f "$appauth_target" ]; then
    cp "$appauth_source" "$appauth_target"
  fi
done
