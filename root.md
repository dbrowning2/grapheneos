# GrapheneOS root

> [!WARNING]  
> MacOS loses the ability to talk to the phone in both adb and fastboot randomly when going between the OS and fastboot.  The ONLY fix I've found is to reboot the Mac.  This has been observed on different generation M series Macbooks.

> [!CAUTION]
> All OS updates will remove root if you do not follow the section for Maintaining root when updating/OTA GrapheneOS.

## Assumptions

This doc makes the following assumptions:
  - You are running GrapheneOS based on Android 16 on a Pixel 9a
  - Developer mode and USB debugging have been enabled and adb/fastboot commands are functional
  - You are connected via USB
  - You have an unlocked bootloader

## Magisk

> [!WARNING]  
> Magisk refuses to accept patches to get Zygisk to work work with GrapheneOS as they are actively blocking root.  There are forks you can use at your own risk https://github.com/pixincreate/Magisk/releases, I tried it, it says it worked but Airalo still didn't function so I don't know if there's much if any benefit.  Don't enable it under stock Magisk.

Download and install the latest non pre-release build from https://github.com/topjohnwu/Magisk/releases.

```
adb install Magisk-v29.0.apk
```

##  Download OTA GrapheneOS and extract init_boot.img

This will automatically download the correct OTA, extract `init_boot.img`, and upload it to `/sdcard/Downloads` so you can patch it with Magisk.

https://github.com/dbrowning2/grapheneos/blob/main/scripts/ota_boot_image.sh

## Magisk steps to get initial root

  - In Magisk click on the `Install` button to the right of `Magisk`.
  - Choose `Select and Patch a File`.
  - Choose the `init_boot.img` file in your `Downloads` that the previous step uploaded to your phone and then tap the `Let's Go` button in the top right.
  - Make Note of the filename the output shows

## Download and flash the patched boot_image.img

This will download the Magisk patched image and flash it.

https://github.com/dbrowning2/grapheneos/blob/main/scripts/download_flash.sh

## Maintaining root when updating/OTA GrapheneOS (untested)

After the update has been installed but you have not rebooted

  - In Magisk click on the `Install` button to the right of `Magisk`.
  - Choose `Install to inactive slot (after OTA)`.
  - Click let's go

If the OS fails to boot get back into fastboot (you should be there).

  - fastboot getvar current-slot
  - fastboot set_active (either a or b, whatever isn't the current slot)
  - reboot

You will be back to your rooted OS pre OTA update.  Perform the OTA update again and reboot.  Follow steps the steps from the beginning.

## Disable Automatic Reboots

Make sure automatic reboots are off in Settings -> System -> System Updates -> Automatic reboot.

## Disable System Updates (optional and not recommended)

To disable system updates entirely go to Settings -> Apps -> See All xx Apps.  In the upper right tap the three dots and select show system.  Find `System Updater`, select it, and disable it.
