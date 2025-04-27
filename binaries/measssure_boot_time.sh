#!/bin/bash

SERIAL_PORT="/dev/ttyACM0"
BAUD=115200
USERNAME="root"
PASSWORD="root"
CSV_FILE="boot_times.csv"
LOG_DIR="boot_logs"
MAX_RUNS=10 

# Create a directory for storing boot logs if it doesn't exist
mkdir -p "$LOG_DIR"

# Initialize CSV file with headers if it doesn't exist
if [ ! -f "$CSV_FILE" ]; then
  echo "boot_log_file,total_boot_time,uboot_time,uncompress_time,kernel_time" > "$CSV_FILE"
fi

# Retry loop until we successfully capture boot times
while true; do
  # Generate a unique log file name for each run
  RUN_NUMBER=$(ls "$LOG_DIR" | wc -l)
  BOOT_LOG_FILE="$LOG_DIR/boot_log_run_$((RUN_NUMBER + 1)).txt"

  if [ $RUN_NUMBER -ge $((MAX_RUNS)) ]; then
    echo "[*] Completed $((MAX_RUNS)) runs."
    break
  fi

  echo "[*] Restarting device on $SERIAL_PORT..."

  # Use stty to configure the serial port
  stty -F $SERIAL_PORT $BAUD raw -echo
  echo -e "\r" > $SERIAL_PORT
  sleep 1
  echo -e "$USERNAME\r" > $SERIAL_PORT
  sleep 1
  echo -e "$PASSWORD\r" > $SERIAL_PORT
  sleep 1
  echo -e "echo b > /proc/sysrq-trigger\r" > $SERIAL_PORT
  echo "[*] Reboot command sent successfully."

  # Start measuring boot time
  echo "[*] Measuring boot time from serial log..."
  # Use grabserial to capture output with pattern matching for boot sequence
  grabserial -d "$SERIAL_PORT" -b $BAUD -t -m "U-Boot 2025.01" -e 20 > "$BOOT_LOG_FILE" 2>/dev/null

  # Check if the boot log is empty and delete if so
  if [ ! -s "$BOOT_LOG_FILE" ]; then
    echo "[!] Boot log file $BOOT_LOG_FILE is empty. Deleting and retrying..."
    rm "$BOOT_LOG_FILE"
    continue
  fi

  # Process the log to calculate boot time
  echo "[*] Boot log captured in $BOOT_LOG_FILE. Analyzing boot time..."

  BOOT_START=0.000000 # We set Grabserial to use this as 0.0sec
  BOOT_END_BOOTLOADER=$(grep -n "Starting kernel ..." "$BOOT_LOG_FILE" | tail -1 | cut -d'+' -f2 | sed 's/^[^[[]*//; s/\[//; s/ .*//')
  BOOT_UNCOMPRESS_TIMESTAMP=$(grep -n "Uncompressing Linux..." "$BOOT_LOG_FILE" | tail -1 | cut -d'+' -f2 | sed 's/^[^[[]*//; s/\[//; s/ .*//')
  BOOT_KERNEL=$(grep -n "Booting Linux on physical CPU 0x0" "$BOOT_LOG_FILE" | tail -1 | cut -d'+' -f2 | sed 's/^[^[[]*//; s/\[//; s/ .*//')
  BOOT_END=$(grep -n "buildroot login:" "$BOOT_LOG_FILE" | tail -1 | cut -d'+' -f2 | sed 's/^[^[[]*//; s/\[//; s/ .*//')

  # If timestamps exist, calculate the time difference
  echo "[*] BOOT_START: $BOOT_START"
  echo "[*] BOOT_END_BOOTLOADER: $BOOT_END_BOOTLOADER"
  echo "[*] BOOT_UNCOMPRESS_TIMESTAMP: $BOOT_UNCOMPRESS_TIMESTAMP"
  echo "[*] BOOT_KERNEL: $BOOT_KERNEL"
  echo "[*] BOOT_END: $BOOT_END"

  # Calculate the time for each phase:
  if [ -n "$BOOT_START" ] && [ -n "$BOOT_END" ]; then
    # Total boot time: From start to login
    TOTAL_BOOT_TIME=$(echo "$BOOT_END - $BOOT_START" | bc)
    echo "[*] Total Boot Time to Userland: $TOTAL_BOOT_TIME seconds"
  else
    echo "[!] Could not determine total boot time. Check '$BOOT_LOG_FILE' for details."
    TOTAL_BOOT_TIME="N/A"
  fi

  if [ -n "$BOOT_START" ] && [ -n "$BOOT_END_BOOTLOADER" ]; then
    # U-Boot time: From start to "Starting kernel ..."
    UBOOT_TIME=$(echo "$BOOT_END_BOOTLOADER - $BOOT_START" | bc)
    echo "[*] U-Boot Time: $UBOOT_TIME seconds"
  else
    echo "[!] Could not determine U-Boot time. Check '$BOOT_LOG_FILE' for details."
    UBOOT_TIME="N/A"
  fi

  # if [ -n "$BOOT_UNCOMPRESS_TIMESTAMP" ] && [ -n "$BOOT_KERNEL" ]; then
  #   # Uncompress time: From "Uncompressing Linux... done" to "Booting Linux on physical CPU 0x0"
  #   UNCOMPRESS_TIME=$(echo "$BOOT_KERNEL - $BOOT_UNCOMPRESS_TIMESTAMP" | bc)
  #   echo "[*] Uncompress Time: $UNCOMPRESS_TIME seconds"
  # else
  #   echo "[!] Could not determine uncompress time. Check '$BOOT_LOG_FILE' for details."
  #   UNCOMPRESS_TIME="N/A"
  # fi
  #
  # if [ -n "$BOOT_KERNEL" ] && [ -n "$BOOT_END" ]; then
  #   # Userland time: From "Booting Linux on physical CPU 0x0" to "buildroot login:"
  #   USERLAND_TIME=$(echo "$BOOT_END - $BOOT_KERNEL" | bc)
  #   echo "[*] Kernel Time: $USERLAND_TIME seconds"
  # else
  #   echo "[!] Could not determine kernel time. Check '$BOOT_LOG_FILE' for details."
  #   USERLAND_TIME="N/A"
  # fi

  # If any of the boot times are N/A, retry
  #if [[ "$TOTAL_BOOT_TIME" == "N/A" || "$UBOOT_TIME" == "N/A" || "$UNCOMPRESS_TIME" == "N/A" || "$USERLAND_TIME" == "N/A" ]]; then
  if [[ "$TOTAL_BOOT_TIME" == "N/A" || "$UBOOT_TIME" == "N/A" ]]; then
    echo "[!] One or more times failed. Retrying..."
    rm "$BOOT_LOG_FILE"  # Delete the failed log
    continue
  fi

  # Log the boot times into CSV file, referencing the log file
  echo "$BOOT_LOG_FILE,$TOTAL_BOOT_TIME,$UBOOT_TIME,$UNCOMPRESS_TIME,$USERLAND_TIME" >> "$CSV_FILE"

  echo "[*] Boot log captured in $BOOT_LOG_FILE."
  echo "[*] Boot time recorded in $CSV_FILE."
  echo "[*] Done."
  
done
