# Intercept wrapper function
git() {
    # 1. Capture the exact arguments passed to git
    RAW_ARGS="$*"
    
    # 2. Run the REAL git command using 'command' to bypass the loop wrapper
    command git "$@"
    EXIT_CODE=$?
    
    # 3. Log the outcome immediately into TOML
    cat << EOF >> "./git_audit.toml"
[[git_actions]]
timestamp = "$(date '+%Y-%m-%d %H:%M:%S')"
user = "$(whoami)"
args = "$RAW_ARGS"
exit_status = $EXIT_CODE
EOF

    # Return the real command's exit code so the user's terminal behaves normally
    return $EXIT_CODE
}
