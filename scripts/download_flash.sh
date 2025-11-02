#!/usr/bin/env bash

set -e

reboot_if_fastboot() {
    if fastboot devices | grep -q .; then
        echo
        echo "Device detected in fastboot → rebooting to OS..."
        fastboot reboot >/dev/null 2>&1 || true
        echo "Reboot command sent."
    fi
}

trap reboot_if_fastboot EXIT


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

echo "Pixel 9a GrapheneOS 16 detected"


echo
echo "Searching for most recent magisk_patched* in /sdcard/Download ..."

latest_magisk="$(adb shell 'ls -t /sdcard/Download/magisk_patched* 2>/dev/null' | head -n 1 | tr -d '\r')"

if [[ -z "$latest_magisk" ]]; then
    echo "No magisk_patched* files found in /sdcard/Download"
    exit 1
fi

echo "Found:"
echo "    $latest_magisk"
echo

read -p "Type 'y' to confirm using this file: " ans
if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
    echo "Canceled"
    exit 1
fi

local_name="$(basename "$latest_magisk")"

echo
echo "Pulling file to local system as $local_name ..."
adb pull "$latest_magisk" "$local_name" >/dev/null || {
    echo "Failed to pull $latest_magisk"
    exit 1
}

echo
read -p "Flash $local_name to **init_boot** partition? Type 'y' to continue: " ans
if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
    echo "Canceled"
    exit 1
fi

logfile="flash_$(date +%Y%m%d_%H%M%S).log"
echo "Logging to $logfile"
echo "Started: $(date)" >> "$logfile"


echo
echo "Rebooting to bootloader..."
adb reboot bootloader


echo "Waiting for fastboot..."
for i in {1..30}; do
    if fastboot devices | grep -q .; then
        break
    fi
    sleep 1
done

if ! fastboot devices | grep -q .; then
    echo "fastboot device not detected"
    exit 1
fi


echo
echo "Flashing patched image to init_boot..."
(
    echo "Flashing $local_name to init_boot"
    fastboot flash init_boot "$local_name"
) &>> "$logfile"

if [[ $? -ne 0 ]]; then
    echo "Flash failed. Check logfile: $logfile"
    exit 1
fi

echo
echo "Flash complete — device will reboot."
echo "Log stored at: $logfile"
echo
