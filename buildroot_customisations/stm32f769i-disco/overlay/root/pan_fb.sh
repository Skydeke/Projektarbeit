#!/bin/hush

# Mount debugfs, ignoring if it's already mounted
mount -t debugfs none /sys/kernel/debug 2>/dev/null

# Check the current state of vpg and vpg_horizontal
current_vpg=$(cat /sys/kernel/debug/40016c00.dsi/vpg)
current_vpg_horizontal=$(cat /sys/kernel/debug/40016c00.dsi/vpg_horizontal)

# Sequential steps based on current values

if [ "$current_vpg" -eq 0 ]; then
    # Step 1: If vpg is off, activate vpg
    echo 1 > /sys/kernel/debug/40016c00.dsi/vpg
    echo "vpg activated." 
elif [ "$current_vpg_horizontal" -eq 0 ]; then
    # Step 2: If vpg is on and vpg_horizontal is 0, flip vpg_horizontal to 1
    echo 1 > /sys/kernel/debug/40016c00.dsi/vpg_horizontal
    echo "vpg_horizontal set to 1."
else
    # Step 3: If vpg is on and vpg_horizontal is 1, turn off vpg and reset fb0 pan
    echo 0 > /sys/kernel/debug/40016c00.dsi/vpg
    echo 0 > /sys/kernel/debug/40016c00.dsi/vpg_horizontal
    echo "vpg deactivated and fb0 pan reset." > /dev/tty1
    echo 1 > /sys/class/graphics/fb0/blank
    echo 0 > /sys/class/graphics/fb0/blank
    echo "DRM console restored." > /dev/tty1
fi
