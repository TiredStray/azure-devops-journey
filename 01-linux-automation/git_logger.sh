#!/bin/bash

# ==============================================================================
# Script Name:  git_logger.sh
# Description:  Bash Function Interceptor for Advanced Telemetry
# Engine:       State Reconciliation (TOML Append -> JSON Compile)
# ==============================================================================


# Define strict, absolute paths
export TARGET_DIR="/home/blearsomnium/projects/azure-devops-journey"
export AUDIT_TOML="$TARGET_DIR/git_audit.toml"
export AUDIT_JSON="$TARGET_DIR/git_audit.json"
export VENV_DIR="$TARGET_DIR/.logger_venv"

# ==============================================================================
# SELF-HEALING & BOOTSTRAPPING CHECK (Universal Cross-Shell Syntax)
# ==============================================================================

# 1. Inspect and repair the target folder layout
if [ ! -d "$TARGET_DIR" ]; then
    echo "⚠️ Target directory does not exist: $TARGET_DIR"
    # Print the prompt message out first to ensure cross-shell compatibility
    echo -n "👉 Create this directory path now? (y/N): "
    read choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        mkdir -p "$TARGET_DIR"
        echo "[✓] Directory constructed."
    else
        echo "[X] Initialization canceled. Telemetry skipped."
        return 1
    fi
fi

# 2. Inspect and repair the Python Virtual Environment & TOML Module
if [ ! -f "$VENV_DIR/bin/python3" ] || ! "$VENV_DIR/bin/python3" -c "import toml" &>/dev/null; then
    echo "⚠️ Isolated Python telemetry runtime or 'toml' module is missing."
    echo -n "👉 Build isolated Virtual Environment and download safe modules? (y/N): "
    read choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "🔧 Provisioning clean environment..."

        if ! dpkg -s python3-venv &>/dev/null; then
            echo "📦 System package 'python3-venv' required."
            sudo apt update && sudo apt install python3-venv -y
        fi

        python3 -m venv "$VENV_DIR"
        "$VENV_DIR/bin/pip" install --upgrade pip &>/dev/null
        "$VENV_DIR/bin/pip" install toml
        echo "[✓] Python dependencies isolated successfully."
    else
        echo "[X] Environment provisioning declined. Telemetry skipped."
        return 1
    fi
fi

# ==============================================================================
# HOOK THE COMMAND WRAPPER
# ==============================================================================
git() {
    local RAW_ARGS="$*"
    local START_TIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    local CURRENT_USER=$(whoami)

    # Run the genuine native binary system command line path
    command git "$@"
    local EXIT_CODE=$?

    # Step 1: Flat TOML layout serialization append block
    if [ ! -f "$AUDIT_TOML" ]; then touch "$AUDIT_TOML"; fi
    cat << EOF >> "$AUDIT_TOML"

[[actions]]
timestamp = "$START_TIME"
user = "$CURRENT_USER"
command_string = "git $RAW_ARGS"
exit_status = $EXIT_CODE
EOF

    # Step 2: Atomic compile routine utilizing our isolated venv interpreter
    # This bypasses PEP 668 restrictions completely by referencing the local binary
    "$VENV_DIR/bin/python3" -c "
import toml, json, os

toml_path = os.environ['AUDIT_TOML']
json_path = os.environ['AUDIT_JSON']

try:
    with open(toml_path, 'r') as f:
        current_data = toml.load(f)

    tmp_path = json_path + '.tmp'
    with open(tmp_path, 'w') as f:
        json.dump(current_data, f, indent=2)

    os.replace(tmp_path, json_path)
except Exception:
    pass
"
    return $EXIT_CODE
}

echo "[✓] Git Telemetry Engine fully hooked and self-healed."
