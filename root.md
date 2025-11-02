# GrapheneOS root

## Warning

MacOS loses the ability to talk to the phone in both adb and fastboot randomly when going between the OS and fastboot.  The ONLY fix I've found is to reboot the Mac.

## Assumptions

This doc makes the following assumptions:
  - You are running GrapheneOS based on Android 16 on a Pixel 9a
  - Deeloper mode and USB debugging have been enabled and adb/fastboot commands are functional and you are connected via USB
  - You have an unlocked bootloader
  - You are unrooted (not tested otherwise)

##  Obtaining pixincreate/Magisk

Magisk refuses to accept patches to work with GrapheneOS as they are actively blocing root so you need to get a patched version that can.  If you have any other version of Magisk installed you must uninstall it.

https://github.com/pixincreate/Magisk/releases

Download to your computer and install:
```
adb install app-release.apk
```

##  Download OTA GrapheneOS and extract init_boot.img

Save this to ota_boot_image.sh and run it:
```
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
```

## pixincreate/Magisk steps

Make sure you are running the pixincreate/Magisk version of Magisk.

  - In Magisk click on the `Install` button to the right of `Magisk`.
  - Choose `Select and Patch a File`.
  - Choose the `init_boot.img` file in your `Downloads` that the previous step uploaded to your phone and then tap the `Let's Go` button in the top right.
  - Make Note of the filename the output shows

## Download and flash the patched boot_image.img

Save this to download_flash.sh and run it:
```
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
```

## OS Updates and root

I have not tested an OS update and trying to use Magisk to directly update in place before rebooting.  It worked on LineageOS unknown on GrapheneOS.  I will update this when I know.
