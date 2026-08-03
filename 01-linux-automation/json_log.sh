# !/bin/bash
# ######################################
# Script Name: json_log.sh
# Description: A simple logger that appends recent actions to a .json file
# Focus: Public Sector Audit Logging & Secure Permissions
#
# ######################################

# 1. Define log file location
JSON_LOG="audit.json"

# 2. Initialize an empty JSON array if the file doesn't exist yet
if [ ! -s "$JSON_LOG" ]; then
    echo "[]" > "$JSON_LOG"
fi

# 3. Capture metadata parameters
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ') # UTC format for cloud engines
USER_NAME=$(whoami)
CMD_RUN="git push origin main"
STATUS_CODE=0

# 4. Use jq to safely inject the object into the existing array
# This reads the file, adds the new object, and updates the file atomically
jq --arg ts "$TIMESTAMP" \
   --arg usr "$USER_NAME" \
   --arg cmd "$CMD_RUN" \
   --argjson code "$STATUS_CODE" \
   '. += [{"timestamp": $ts, "user": $usr, "command": $cmd, "status": $code}]' \
   "$JSON_LOG" > temp.json && mv temp.json "$JSON_LOG"

