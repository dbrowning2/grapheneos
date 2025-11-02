#!/usr/bin/env bash

adb get-state >/dev/null 2>&1 || {
    echo "No ADB device detected"
    exit 2
}

if [[ "$(adb shell getprop ro.build.version.release | tr -d '\r')" != "16" ]]; then
    echo "Not Android 16"
    exit 1
fi

if ! adb shell pm list packages -s | grep -q "app.grapheneos.info"; then
    echo "Not GrapheneOS"
    exit 1
fi

if [[ "$(adb shell getprop ro.product.device | tr -d '\r')" != "tegu" ]]; then
    echo "Not Pixel 9a"
    exit 1
fi

build_number="$(adb shell getprop ro.build.fingerprint | cut -d'/' -f5 | cut -d':' -f1)"
echo "Pixel 9a GrapheneOS 16 $build_number detected"

filename="tegu-install-$build_number.zip"
url="https://releases.grapheneos.org/$filename"

if [[ -f "$filename" ]]; then
    echo "$filename exists"
else
    echo "Downloading $filename"
    curl -# -O "$url"
fi

echo "Extracting init_boot.img (this can take some time)"

if ! unzip -o -j "$filename" "tegu-install-$build_number/init_boot.img" >/dev/null 2>&1; then
    echo "init_boot.img not found in ZIP"
    exit 1
fi

echo "init_boot.img extracted"

target="/sdcard/Download"

if adb shell ls "$target/init_boot.img" >/dev/null 2>&1; then
    echo "Existing init_boot.img found on device, removing"
    adb shell rm -f "$target/init_boot.img"
fi

echo "Uploading new init_boot.img"
adb push init_boot.img "$target/init_boot.img" >/dev/null

echo "Uploaded init_boot.img to Download/"
