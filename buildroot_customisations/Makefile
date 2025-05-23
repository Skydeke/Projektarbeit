PREFIX = $(shell pwd)/..
url_buildroot = https://github.com/buildroot/buildroot.git
dir_external = $(PREFIX)/buildroot_customisations
dir_buildroot = $(PREFIX)/buildroot
dir_output = $(dir_buildroot)/output
release_tag = 2024.08.3

bootstrap:
	@echo "Downloading buildroot to $(PREFIX)"
	git clone --depth 10 "$(url_buildroot)" "$(dir_buildroot)"
	cd "$(dir_buildroot)" && git fetch --tags && git reset --hard "$(release_tag)"
	make BR2_EXTERNAL="$(dir_external)" custom_stm32f769_defconfig -C "$(dir_buildroot)"

linux-rebuild:
	make linux-rebuild -C "$(dir_buildroot)"

build:
	make -C $(dir_buildroot)

save_all:
	make update-defconfig -C "$(dir_buildroot)"
	make linux-update-defconfig -C "$(dir_buildroot)"
	make busybox-update-config -C "$(dir_buildroot)"
	make uclibc-update-config -C "$(dir_buildroot)"
	make uboot-update-defconfig -C "$(dir_buildroot)"

flash_bootloader:
	cd "$(dir_output)/build/host-openocd-0.12.0/tcl" && openocd \
		-f board/stm32f7discovery.cfg \
		-c "init" \
		-c "reset init" \
		-c "flash probe 0" \
		-c "flash info 0" \
		-c "flash write_image erase ${dir_output}/images/u-boot.bin 0x08000000" \
		-c "reset run" \
		-c "shutdown"

clean:
	make clean world -C $(dir_buildroot)
