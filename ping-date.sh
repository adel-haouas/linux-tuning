#!/bin/bash

HOST=$1
COLOR_DATE="\033[1;34m"   # Blue color for date
COLOR_PING_OK="\033[1;32m" # Green color for successful ping
COLOR_PING_FAIL="\033[1;31m" # Red color for failed ping
COLOR_RESET="\033[0m"     # Reset color

if [ -z "$HOST" ]; then
  echo "Usage: $0 <host>"
  exit 1
fi

while true; do
  # Get the current date and time
  CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

  # Get the ping result with a timeout of 1 second
  PING_RESULT=$(ping -4 -c 1 -W 1 $HOST 2>&1)
  PING_STATUS=$?

  if [ $PING_STATUS -eq 0 ]; then
    # Extract the relevant part of the ping result for success
    PING_RESULT=$(echo "$PING_RESULT" | grep 'bytes from')
    # Print date and ping result in the same line
    echo -e "${COLOR_DATE}${CURRENT_DATE}${COLOR_RESET} ${COLOR_PING_OK}${PING_RESULT}${COLOR_RESET}"
  else
    # Indicate the host is unreachable
    echo -e "${COLOR_DATE}${CURRENT_DATE}${COLOR_RESET} ${COLOR_PING_FAIL}Host $HOST is unreachable${COLOR_RESET}"
  fi

  sleep 1
done
