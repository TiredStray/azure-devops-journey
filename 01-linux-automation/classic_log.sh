# ==============================================================================
# Script Name:  classic_log.sh
# Description:  A simple plain text audit log for git.	
# Focus:        Public Sector Audit Logging & Secure Permissions
# ==============================================================================

#capture metadata
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
USER_NAME=$(whoami)
COMMAND_ARGUMENTS="git commit -m 'initial commit'"
#IAA="in an actual"
#IAA command arguments need to be dynamically inserted
# edge - static cases where the command does not accept arguments
EXIT_STATUS=0

LOG_ENTRY="[$TIMESTAMP] USER: $USER_NAME | CMD: $COMMAND_ARGUMENT | STATUS: $EXIT_STATUS"

#append directly to text file
echo "$LOG_ENTRY" >> audit.log
#IAA if this fails can it break the flow? will it break silently?
#this should be wrapped with an alternate create the file or escape with alarm decision.
