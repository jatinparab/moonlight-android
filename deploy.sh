#!/usr/bin/env bash
set -euo pipefail

TV_IP="${TV_IP:-192.168.1.128}"
ADB_PORT="${ADB_PORT:-5555}"
ADB_TARGET="${TV_IP}:${ADB_PORT}"
BUILD_TASK="${BUILD_TASK:-assembleNonRootRelease}"
APK_PATH="${APK_PATH:-app/build/outputs/apk/nonRoot/release/app-nonRoot-release.apk}"
KEYSTORE_PATH="/tmp/moonlight-release.jks"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb is required but was not found in PATH" >&2
  exit 1
fi

if [[ ! -x ./gradlew ]]; then
  echo "./gradlew is missing or not executable" >&2
  exit 1
fi

if [[ ! -f "${KEYSTORE_PATH}" ]]; then
  if ! command -v keytool >/dev/null 2>&1; then
    echo "keytool is required to create ${KEYSTORE_PATH}" >&2
    exit 1
  fi

  keytool -genkeypair \
    -keystore "${KEYSTORE_PATH}" \
    -storepass moonlight123 \
    -keypass moonlight123 \
    -alias moonlight \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=Moonlight Local, OU=Local, O=Local, L=Local, ST=Local, C=US"
fi

./gradlew "${BUILD_TASK}"

adb connect "${ADB_TARGET}"
adb -s "${ADB_TARGET}" install -r "${APK_PATH}"

echo "Installed ${APK_PATH} on ${ADB_TARGET}"
