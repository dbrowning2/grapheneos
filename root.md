# GrapheneOS root

> [!IMPORTANT]  
> Pay special attention to the pixincreate/Magisk section.  If you use stock Magisk you will soft brick your phone although it is easily recoverable it does require you to wipe your phone.

> [!WARNING]  
> MacOS loses the ability to talk to the phone in both adb and fastboot randomly when going between the OS and fastboot.  The ONLY fix I've found is to reboot the Mac.  This has been reproduced on different generation M series Macbooks.

> [!CAUTION]
> All OS updates will remove root.  You will have to run through this after every OS upgrade.  You can not do a direct in place root via Magisk after an update and before a reboot.  It won't hurt anything but it also won't work.

## Assumptions

This doc makes the following assumptions:
  - You are running GrapheneOS based on Android 16 on a Pixel 9a
  - Deeloper mode and USB debugging have been enabled and adb/fastboot commands are functional
  - You are connected via USB
  - You have an unlocked bootloader
  - You are not rooted

## Obtaining pixincreate/Magisk

Magisk refuses to accept patches to work with GrapheneOS as they are actively blocing root so you need to get a patched version that can.  If you have any other version of Magisk installed you must uninstall it.

https://github.com/pixincreate/Magisk/releases

Download to your computer and install:
```
adb install app-release.apk
```

##  Download OTA GrapheneOS and extract init_boot.img

This will automatically download the correct OTA, extract init_boot.img, and upload it to `/sdcard/Downloads` so you can patch it with Magisk.

https://github.com/dbrowning2/grapheneos/blob/main/scripts/ota_boot_image.sh

## pixincreate/Magisk steps

Make sure you are running the pixincreate/Magisk version of Magisk.

  - In Magisk click on the `Install` button to the right of `Magisk`.
  - Choose `Select and Patch a File`.
  - Choose the `init_boot.img` file in your `Downloads` that the previous step uploaded to your phone and then tap the `Let's Go` button in the top right.
  - Make Note of the filename the output shows

## Download and flash the patched boot_image.img

This will download the Magisk patched image and flash it.

https://github.com/dbrowning2/grapheneos/blob/main/scripts/download_flash.sh
