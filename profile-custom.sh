#!/bin/sh
# /etc/profile.d/custom.sh - Global environment and aliases

# --- System Settings ---
# Note: On modern Linux, it is recommended to set these via system commands:
# localectl set-locale LANG=en_US.UTF-8
# timedatectl set-timezone Africa/Tunis
# If you must force them here, uncomment the following:
# export LANG=en_US.UTF-8
# export TZ='Africa/Tunis'

umask 022                     # Set default permissions (755 for dirs, 644 for files)

# --- POSIX-Compliant History Settings ---
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTTIMEFORMAT="%d/%m/%Y__%T # "

# --- Bash-Specific Configuration ---
if [ -n "$BASH_VERSION" ]; then
    # History behavior
    shopt -s histappend                     # Append history instead of overwriting
    export HISTCONTROL=ignoreboth:erasedups # Ignore duplicates and erase them
    PROMPT_COMMAND='history -a'             # Immediately save history after each command

    # Colors
    export GREP_COLORS='mt=1;32'
    export COLOR_NC='\033[0m'      # No Color
    export COLOR_BLACK='\033[0;30m'
    export COLOR_GRAY='\033[1;30m'
    export COLOR_RED='\033[0;31m'
    export COLOR_LIGHT_RED='\033[1;31m'
    export COLOR_GREEN='\033[0;32m'
    export COLOR_LIGHT_GREEN='\033[1;32m'
    export COLOR_BROWN='\033[0;33m'
    export COLOR_YELLOW='\033[1;33m'
    export COLOR_BLUE='\033[0;34m'
    export COLOR_LIGHT_BLUE='\033[1;34m'
    export COLOR_PURPLE='\033[0;35m'
    export COLOR_LIGHT_PURPLE='\033[1;35m'
    export COLOR_CYAN='\033[0;36m'
    export COLOR_LIGHT_CYAN='\033[1;36m'
    export COLOR_LIGHT_GRAY='\033[0;37m'
    export COLOR_WHITE='\033[1;37m'

    UC=$COLOR_WHITE               # user's color
    [ "$UID" -eq "0" ] && UC=$COLOR_RED

    TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    PS1="$TITLEBAR\n\[${UC}\]\u${COLOR_LIGHT_GREEN}@${COLOR_GREEN}\h \[${COLOR_LIGHT_BLUE}\]\${PWD} \[${COLOR_BLACK}\]\ \n\[${COLOR_LIGHT_GREEN}\]→\[${COLOR_NC}\] "

    # Aliases
    alias grep='grep --color=auto'
    alias ll='ls --color=auto -lh'
    alias tf='tail -f '
    alias ip='ip -c '
    alias ccze='ccze -A'
    alias mdf='free -mh|ccze -A;printf '%.0s.' {1..80};echo;df -h|egrep -v "tmpfs|loop"|ccze -A;printf '%.0s.' {1..80};echo;w'

fi
