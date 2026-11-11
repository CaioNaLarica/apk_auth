#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! curl --silent --fail http://127.0.0.1:4400/emulators > /dev/null; then
  echo 'Primeiro execute npm run emulators em outro terminal.'
  exit 1
fi
flutter run -d "${1:-emulator-5554}"
