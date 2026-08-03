#!/bin/bash
 ###################################
## script name: gith.sh            #
## description: state              #
##  reconciliation loop            #
## focus: public sector audit      #
##  logging and secure permissions #
##                                 #
###################################
##################################

# Define our storage targets
TOML_DB="audit.toml"
JSON_OUTPUT="audit.json"

# Capture metadata arguments passed to the script
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ') # ISO-8601 UTC
USER_NAME=$(whoami)
COMMAND_RUN="${1:-no-command-provided}"
EXIT_STATUS="${2:-0}"

# --- STEP 1: Append Cleanly to TOML ---
# Check if TOML file exists; if not, initialize it
if [ ! -f "$TOML_DB" ]; then
    touch "$TOML_DB"
fi

# Append the new log chunk cleanly using a standard Here Document
cat << EOF >> "$TOML_DB"

[[logs]]
timestamp = "$TIMESTAMP"
user = "$USER_NAME"
command = "$COMMAND_RUN"
status = $EXIT_STATUS
EOF

echo "[✓] Appended cleanly to $TOML_DB"

# --- STEP 2: Translate and Compile to JSON ---
# We use an inline Python micro-script to handle the object compilation.
# This completely eliminates recursive formatting bugs.
python3 -c "
import toml, json

try:
    # Read the clean TOML data store
    with open('$TOML_DB', 'r') as f:
        data = toml.load(f)
    
    # Overwrite the output file with pristine, minified JSON
    with open('$JSON_OUTPUT', 'w') as f:
        json.dump(data, f, indent=2)
    print('[✓] Successfully compiled and synchronized $JSON_OUTPUT')
except Exception as e:
    print(f'[X] Reconciler Error: {e}')
"

# no string invalidation
# single source of truth
# human and machine balanced

