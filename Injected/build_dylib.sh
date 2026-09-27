#!/bin/bash
set -euo pipefail

SDKROOT="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANG="$(xcrun --sdk iphoneos --find clang)"
mkdir -p build

"$CLANG" \
  -arch arm64 \
  -isysroot "$SDKROOT" \
  -miphoneos-version-min=15.1 \
  -fobjc-arc \
  -dynamiclib \
  Injected/EOBOTEROverlay.m \
  -framework UIKit \
  -framework Foundation \
  -Wl,-install_name,@executable_path/Frameworks/EOBOTER.dylib \
  -o build/EOBOTER.dylib

file build/EOBOTER.dylib
xcrun vtool -show-build build/EOBOTER.dylib || true
