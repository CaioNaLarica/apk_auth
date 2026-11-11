#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
appauth_sdk="${ANDROID_HOME:-$HOME/Android/Sdk}"
if [ ! -f "$appauth_sdk/system-images/android-24/default/x86_64/package.xml" ]; then
  echo "Instale a imagem com: $appauth_sdk/cmdline-tools/latest/bin/sdkmanager 'system-images;android-24;default;x86_64'"
  exit 1
fi
appauth_avd_root="$PWD/.android-emulator"
mkdir -p "$appauth_avd_root/AppAuth_Light.avd"
if [ ! -f "$appauth_avd_root/AppAuth_Light.avd/config.ini" ]; then
  cp scripts/emulator_config.ini "$appauth_avd_root/AppAuth_Light.avd/config.ini"
fi
cat > "$appauth_avd_root/AppAuth_Light.ini" <<AVD
avd.ini.encoding=UTF-8
path=$appauth_avd_root/AppAuth_Light.avd
target=android-24
AVD
export ANDROID_AVD_HOME="$appauth_avd_root"
exec "$appauth_sdk/emulator/emulator" -avd AppAuth_Light -no-snapshot -no-boot-anim -gpu host -feature -Vulkan -no-audio -memory 1024 -cores 2
