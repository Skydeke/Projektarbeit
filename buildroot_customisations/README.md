STM32F769 Discovery
===================

This describes how to use and customize the Buildroot configuration for the STM32F769 Discovery evaluation platform.

Configuration
------------- 


```
    # Configure Buildroot
    cd buildroot
    make menuconfig
    make uboot-menuconfig
    make linux-menuconfig
    make uclibc-menuconfig
    #Save Buildroot Config to customisations
    cd buildroot_customisations
    make save_all
```

Building
--------


```
    cd buildroot_customisations
    make build
```
Flashing
--------


```
  cd buildroot_customisations
  make flash_bootloader
```

Creating SD card
----------------

Buildroot prepares an"sdcard.img" image in the buildroot/output/images/ directory,
ready to be dumped on a SD card. Launch the following command as root:
```
  cd buildroot/output/images/
  dd if=sdcard.img of=/dev/<your-sd-device>
```

*** WARNING! This will destroy all the card content. Use with care! ***

For details about the medium image layout and its content, see buildroot_customisations/stm32f769i-disco/genimage.cfg.

