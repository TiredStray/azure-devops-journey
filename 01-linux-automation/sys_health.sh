#!/bin/bash

# ==============================================================================
# Script Name:  sys_health.sh
# Description:  DevOps System Health Monitor for Disk and Memory
# Focus:        Public Sector Audit Logging & Secure Permissions
# ==============================================================================

# 1. Define strict logging directory and files
LOG_DIR="./secure_logs"
LOG_FILE="$LOG_DIR/system_alerts.log"

# Create the log directory if it does not exist
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    # Secure the log folder immediately: Only owner can Read/Write/Execute (700)
    chmod 700 "$LOG_DIR"
fi

# 2. Set thresholds (Hospitals/Gov systems alert early)
DISK_THRESHOLD=80
MEM_THRESHOLD=85

echo "--- Running DevOps System Audit: $(date) ---"

# 3. Parse current Disk Usage using df and awk
# df / pulls disk data; awk grabs the percentage column, tr removes the '%' sign
CURRENT_DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Current Disk Usage: $CURRENT_DISK%"

if [ "$CURRENT_DISK" -gt "$DISK_THRESHOLD" ]; then
    ALERT_MSG="[ALERT] $(date) - High Disk Usage: $CURRENT_DISK% (Threshold: $DISK_THRESHOLD%)"
    echo "$ALERT_MSG" | tee -a "$LOG_FILE"
fi

# 4. Parse current Memory Usage using free and awk
# free -m tracks megabytes; awk calculates used vs total percentage
CURRENT_MEM=$(free | awk '/Mem:/ {printf("%.0f\n", $3/$2 * 100)}')
echo "Current Memory Usage: $CURRENT_MEM%"

if [ "$CURRENT_MEM" -gt "$MEM_THRESHOLD" ]; then
    ALERT_MSG="[ALERT] $(date) - High Memory Usage: $CURRENT_MEM% (Threshold: $MEM_THRESHOLD%)"
    echo "$ALERT_MSG" | tee -a "$LOG_FILE"
fi

# 5. Clean operational exit
echo "Audit complete."
exit 0

