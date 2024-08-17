#!/bin/bash

#######################################################
bold=$(tput bold) #Set text to bold formatting using ANSI escape code
reset=$(tput sgr0) #Reset Text Formatting
blink='\e[5m' #ANSI escape code sequence for blinking text

# Define foreground color escape codes
black=$(tput setaf 0);red=$(tput setaf 1);green=$(tput setaf 2);yellow=$(tput setaf 3)
blue=$(tput setaf 4);magenta=$(tput setaf 5);cyan=$(tput setaf 6);white=$(tput setaf 7)
orange=$(tput setaf 166);purple=$(tput setaf 92);teal=$(tput setaf 30)

# Define background color escape codes
bg_black=$(tput setab 0);bg_red=$(tput setab 1);bg_green=$(tput setab 2);bg_yellow=$(tput setab 3)
bg_blue=$(tput setab 4);bg_magenta=$(tput setab 5);bg_cyan=$(tput setab 6);bg_white=$(tput setab 7)
bg_orange=$(tput setab 166);bg_purple=$(tput setab 92);bg_teal=$(tput setab 30)
########################################################

# Get CPU information
vcpu_count=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
CPUModel=$(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}' | sed -e 's/^[ \t]*//')

# Get HDD information
total_hdd=$(df -h --total | awk '/^total/ {print $2}')

linux_distro=$(cat /etc/*release | grep '^PRETTY_NAME=' | cut -d '"' -f 2) #Get Linux distribution information
total_ram=$(free -h | awk '/^Mem:/ {print $2}') #Get RAM information

SystemLoad=$(uptime | awk -F'[a-z]:' '{print $2}')
Uptime=$(uptime | awk '{print $3" "$4" "$5" "$6}'|awk -F"," '{print $1", "$2}')

echo "${bg_red}${bold}${white}### System Information ###${reset}"
echo "${bold}${green}Linux Distribution:${reset} $linux_distro"
echo "${bold}CPU:${reset} $vcpu_count x $CPUModel"
echo "${bold}System Load (1 min, 5 mins, 15 mins):${reset}$SystemLoad"
echo "${bold}Uptime:${reset} $Uptime"

echo "${bold}Global IPv4:${reset} $(curl -s -4 icanhazip.com)";
echo ""
echo "${bold}RAM:${reset} $(free -hm)"
echo ""

echo "### Disks and Partitions Information ###"
echo "${bold}HDD:${reset} $total_hdd"
echo "${bold}Partitions:${reset}"
df -hT|egrep -v "tmpfs"
echo ""
