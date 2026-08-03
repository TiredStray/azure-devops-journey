#!/bin/bash

# ==============================================================================
# Script Name:  toml_log.sh
# Description:  logs git status on a toml file, useful for cron updates.`
# Focus:        Public Sector Audit Logging & Secure Permissions
# ==============================================================================


TOML_LOG="audit.toml"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
USER_NAME=$(whoami)
CMD_RUN="git status"
STATUS_CODE=0

# Appending a discrete block of TOML parameters
cat << EOF >> "$TOML_LOG"

[[log_entries]]
timestamp = "$TIMESTAMP"
user = "$USER_NAME"
command = "$CMD_RUN"
status = $STATUS_CODE
EOF


