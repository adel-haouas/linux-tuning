#!/bin/bash

# ==========================================
# BEAUTIFUL DIAGNOSTICS SCRIPT (V5.7)
# chmod +x beautiful_diag.sh
# echo "alias diag='~/beautiful_diag.sh'" >> .bashrc; source .bashrc
# ==========================================

BAR_LENGTH=30
COL_WIDTH=56
SEPARATOR="⁞⁞ "
SEP_COLOR="216"   # Modern soft teal. Try 117 (cyan), 183 (mauve), 216 (peach), 141 (purple).

BOLD='\033[1m'
RESET='\033[0m'

function header {
 echo -e "${BOLD}\033[38;5;204m### $1 ###${RESET}"
}

function title {
 echo -en "${BOLD}\033[38;5;190m$1${RESET}"
}

draw_bar_str() {
    awk -v label="$1" -v percent="$2" -v bar_len="$BAR_LENGTH" 'BEGIN {
        percent = int(percent)
        if (percent > 100) percent = 100
        if (percent < 0) percent = 0

        if (percent >= 90) color = 203;
        else if (percent >= 75) color = 214;
        else color = 114;

        filled = int((percent * bar_len) / 100)
        empty = bar_len - filled

        bar_filled = ""
        for (i = 0; i < filled; i++) bar_filled = bar_filled "█"

        bar_empty = ""
        for (i = 0; i < empty; i++) bar_empty = bar_empty "░"

        printf "%s |\033[38;5;%sm%s\033[38;5;240m%s\033[0m| \033[38;5;214m%3d%%\033[0m", label, color, bar_filled, bar_empty, percent
    }'
}

draw_bar() {
    draw_bar_str "$1" "$2"
    echo ""
}

# ==========================================
# SPARKLINE HELPER
# ==========================================
render_sparkline() {
    local current="$1"
    local history_file="$HOME/.beautiful_diag_history"
    local max_samples=30

    echo "$(date +%s) $current" >> "$history_file"

    if [ $(wc -l < "$history_file") -gt $max_samples ]; then
        tail -n $max_samples "$history_file" > "${history_file}.tmp" && mv "${history_file}.tmp" "$history_file"
    fi

    awk '
    BEGIN {
        split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", blocks, " ");
        n = 0; max = 0; min = 999999;
    }
    {
        n++;
        val[n] = $2 + 0;
        if (val[n] > max) max = val[n];
        if (val[n] < min) min = val[n];
    }
    END {
        if (n == 0) { printf "\033[2m(no history yet)\033[0m"; exit; }
        scale_max = max;
        if (scale_max < 0.01) scale_max = 0.01;
        printf "\033[38;5;114m";
        for (i = 1; i <= n; i++) {
            idx = int((val[i] / scale_max) * 7) + 1;
            if (idx < 1) idx = 1;
            if (idx > 8) idx = 8;
            printf "%s", blocks[idx];
        }
        printf "\033[0m";
        printf "  \033[2m(min: %.2f  max: %.2f)\033[0m", min, max;
    }' "$history_file" 2>/dev/null
}

strip_ansi() {
    sed -E 's/\x1b\[[0-9;]*m//g'
}

print_two_cols() {
    local left="$1"
    local right="$2"

    local left_plain=$(printf "%b" "$left" | strip_ansi)
    local left_len=${#left_plain}
    local pad=$(( COL_WIDTH - left_len ))
    if [ "$pad" -lt 1 ]; then pad=1; fi

    printf "%b" "$left"
    printf "%${pad}s" ""
    printf "%b\n" "$right"
}

# ==========================================
# SECTION 0: SYSTEM INFORMATION
# ==========================================
header "System Information"

if [ -f /etc/os-release ]; then
    OS_NAME=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
else
    OS_NAME=$(uname -s)
fi
title "Linux Distribution: "
echo -e "${RESET} ${OS_NAME}"

CORES=$(nproc)
CPU_MODEL=$(lscpu | grep "Model name" | sed 's/Model name:[ \t]*//' | head -n 1)
if [ -z "$CPU_MODEL" ]; then
    CPU_MODEL=$(grep -m 1 'model name' /proc/cpuinfo | sed 's/.*: //')
fi
title "CPU: "
echo -e "${RESET} ${CORES} x ${CPU_MODEL}"

IP_ADDR=$(hostname -I | awk '{print $1}')
title "Global IPv4: "
echo -e "${RESET} ${IP_ADDR}"
echo ""

# ==========================================
# SECTION 1: UPTIME & LOAD AVERAGE
# ==========================================
header "Uptime"

UPTIME_RAW=$(uptime)
LOAD_1=$(echo "$UPTIME_RAW" | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
LOAD_5=$(echo "$UPTIME_RAW" | awk -F'load average:' '{print $2}' | awk -F',' '{print $2}' | tr -d ' ')
LOAD_15=$(echo "$UPTIME_RAW" | awk -F'load average:' '{print $2}' | awk -F',' '{print $3}' | tr -d ' ')

echo -e " \033[38;5;255m${UPTIME_RAW}\033[0m"
echo -e "\033[2m# load average = tasks running or waiting\033[0m"

P1=$(echo "$LOAD_1 $CORES" | awk '{printf "%.0f", ($1/$2)*100}')
P5=$(echo "$LOAD_5 $CORES" | awk '{printf "%.0f", ($1/$2)*100}')
P15=$(echo "$LOAD_15 $CORES" | awk '{printf "%.0f", ($1/$2)*100}')

BAR1=$(draw_bar_str "1 min " "$P1")
BAR5=$(draw_bar_str "5 min " "$P5")
BAR15=$(draw_bar_str "15 min" "$P15")

printf "%b   %b   %b\n" "$BAR1" "$BAR5" "$BAR15"

echo -n "History |"
render_sparkline "$LOAD_1"
echo ""
echo ""

# ==========================================
# SECTION 2: MEMORY USAGE
# ==========================================
header "Memory & Swap"

MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
MEM_AVAIL=$(free -m | awk '/^Mem:/{print $7}')
MEM_USED=$((MEM_TOTAL - MEM_AVAIL))
MEM_PERCENT=$(( MEM_USED * 100 / MEM_TOTAL ))

SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')
SWAP_USED=$(free -m | awk '/^Swap:/{print $3}')
if [ "$SWAP_TOTAL" -gt 0 ]; then
    SWAP_PERCENT=$(( SWAP_USED * 100 / SWAP_TOTAL ))
else
    SWAP_PERCENT=0
fi

if [ "$MEM_TOTAL" -gt "$SWAP_TOTAL" ]; then
    MAX_TOTAL=$MEM_TOTAL
else
    MAX_TOTAL=$SWAP_TOTAL
fi
TOTAL_WIDTH=${#MAX_TOTAL}

MEM_USED_PAD=$(printf "%${TOTAL_WIDTH}s" "$MEM_USED")
SWAP_USED_PAD=$(printf "%${TOTAL_WIDTH}s" "$SWAP_USED")
MEM_TOTAL_PAD=$(printf "%${TOTAL_WIDTH}s" "$MEM_TOTAL")
SWAP_TOTAL_PAD=$(printf "%${TOTAL_WIDTH}s" "$SWAP_TOTAL")

LEFT_MEM_LINE1="Mem:   ${MEM_USED_PAD}Mi used / ${MEM_TOTAL_PAD}Mi total"
LEFT_MEM_LINE2="Swap:  ${SWAP_USED_PAD}Mi used / ${SWAP_TOTAL_PAD}Mi total"

RIGHT_MEM_LINE1=$(draw_bar_str "Mem " "$MEM_PERCENT")
RIGHT_MEM_LINE2=$(draw_bar_str "Swap" "$SWAP_PERCENT")

LEFT_MEM_LINE1="\033[38;5;255m${LEFT_MEM_LINE1}\033[0m"
LEFT_MEM_LINE2="\033[38;5;255m${LEFT_MEM_LINE2}\033[0m"

print_two_cols "$LEFT_MEM_LINE1" "$RIGHT_MEM_LINE1"
print_two_cols "$LEFT_MEM_LINE2" "$RIGHT_MEM_LINE2"
echo ""
echo -e "\033[38;5;214m${MEM_AVAIL}Mi\033[0m available of ${MEM_TOTAL}Mi"
echo ""

# ==========================================
# SECTION 3: DISK USAGE
# ==========================================
header "Partitions"

echo -e "Filesystem                  Size  Used Avail Use% Mounted on"

process_mount_str() {
    local mount_point="$1"
    if mountpoint -q "$mount_point" 2>/dev/null || df "$mount_point" >/dev/null 2>&1; then
        local fs=$(df -h "$mount_point" | awk 'NR==2 {print $1}')
        local total=$(df -h "$mount_point" | awk 'NR==2 {print $2}')
        local used=$(df -h "$mount_point" | awk 'NR==2 {print $3}')
        local avail=$(df -h "$mount_point" | awk 'NR==2 {print $4}')
        local percent=$(df -h "$mount_point" | awk 'NR==2 {print $5}' | tr -d '%')

        printf "%-27s %5s %5s %5s %4s%% %s\n" "$fs" "$total" "$used" "$avail" "$percent" "$mount_point"
        echo "$percent"
    fi
}

ROOT_P=$(process_mount_str "/" | tail -n 1)
process_mount_str "/" | head -n -1
BOOT_P=$(process_mount_str "/boot" | tail -n 1)
process_mount_str "/boot" | head -n -1

ROOT_BAR=$(draw_bar_str "Root " "$ROOT_P")
BOOT_BAR=$(draw_bar_str "Boot " "$BOOT_P")
printf "%b   %b\n" "$ROOT_BAR" "$BOOT_BAR"
echo ""

# ==========================================
# NETWORK STATS — 2 NICs PER ROW WITH SEPARATOR
# ==========================================
header "Network"

NET_TMP=$(mktemp)

awk '
function humanize(bytes,    units, i, size) {
    split("B KiB MiB GiB TiB", units, " ");
    size = bytes;
    i = 1;
    while (size >= 1024 && i < 5) { size /= 1024; i++; }
    if (i == 1) return sprintf("%d %s", size, units[i]);
    return sprintf("%.2f %s", size, units[i]);
}
function status_color(state) {
    if (state == "up")      return "114";
    if (state == "down")    return "203";
    if (state == "dormant") return "214";
    return "240";
}
NR>2 {
    gsub(/^[ \t]+/, "");
    split($0, arr, ":");
    iface = arr[1];
    gsub(/^[ \t]+/, "", iface);
    if (iface == "lo" || iface ~ /^tun/) next;
    stats = arr[2];
    split(stats, s, " ");
    n = 0;
    for (i in s) if (s[i] != "") { n++; vals[n] = s[i]; }
    rx = vals[1];
    tx = vals[9];

    state_file = "/sys/class/net/" iface "/operstate";
    state = "unknown";
    if ((getline st < state_file) > 0) {
        state = st;
        close(state_file);
    }

    if (rx < 1048576 && tx < 1048576 && state != "down") next;

    color = status_color(state);
    state_upper = toupper(state);
    status_tag = sprintf("\033[38;5;%sm[%-5s]\033[0m", color, state_upper);

    printf "  \033[38;5;255m%-8s\033[0m  %s  RX: %-10s  TX: %s\n", iface, status_tag, humanize(rx), humanize(tx);
}' /proc/net/dev > "$NET_TMP"

NIC_COUNT=$(wc -l < "$NET_TMP")

if [ "$NIC_COUNT" -eq 0 ]; then
    echo -e "\033[2m# All interfaces have less than 1 MiB of traffic.\033[0m"
else
    NIC_LINES=()
    while IFS= read -r line; do
        NIC_LINES+=("$line")
    done < "$NET_TMP"

    PADDED=()
    for line in "${NIC_LINES[@]}"; do
        plain=$(printf "%b" "$line" | strip_ansi)
        len=${#plain}
        pad=$(( COL_WIDTH - len ))
        if [ "$pad" -lt 1 ]; then pad=1; fi
        PADDED+=("$(printf "%b%${pad}s" "$line" "")")
    done

    # Modern separator with configurable color
    SEP_COLORED="\033[38;5;${SEP_COLOR}m${SEPARATOR}\033[0m"

    i=0
    while [ $i -lt ${#PADDED[@]} ]; do
        left="${PADDED[$i]}"
        right=""
        if [ $((i + 1)) -lt ${#PADDED[@]} ]; then
            right="${PADDED[$((i + 1))]}"
        fi
        if [ -n "$right" ]; then
            printf "%b%b%b\n" "$left" "$SEP_COLORED" "$right"
        else
            printf "%b\n" "$left"
        fi
        i=$((i + 2))
    done
fi

rm -f "$NET_TMP"
echo ""

# ==========================================
# TOP PROCESSES
# ==========================================
header "Top 5 Processes by CPU"

PROC_OUTPUT=$(ps aux --sort=-%cpu | awk '
    NR>1 && $3 != "0.0" {
        printf "%-10s %5s %5s %s\n", $1, $3, $4, $11
    }
' | head -n 5 | cut -c1-80)

if [ -n "$PROC_OUTPUT" ]; then
    printf "\033[2m%-10s %5s %5s %s\033[0m\n" "USER" "CPU%" "MEM%" "COMMAND"
    echo "$PROC_OUTPUT"
else
    echo -e "\033[2m# All processes are idle (0.0% CPU).\033[0m"
fi
echo ""

# ==========================================
# DOCKER STATUS
# ==========================================
if command -v docker >/dev/null 2>&1; then
    header "Docker Containers"
    DOCKER_COUNT=$(docker ps -q 2>/dev/null | wc -l)
    if [ "$DOCKER_COUNT" -gt 0 ]; then
        printf "\033[2m%-15s %-20s %-10s %s\033[0m\n" "CONTAINER ID" "IMAGE" "STATUS" "NAMES"
        docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" 2>/dev/null | awk 'NR>1 {printf "%-15s %-20s %-10s %s\n", $1, $2, $3, $4}' | cut -c1-100
    else
        echo -e "\033[2m# Docker installed but no containers are running.\033[0m"
    fi
    echo ""
fi

# ==========================================
# LOGGED IN USERS (w)
# ==========================================
header "w"
w | head -n 10
echo ""

# ==========================================
# LAST 5 LOGINS
# ==========================================
header "Last 5 Logins"

if [ -s /var/log/wtmp ]; then
    LAST_OUTPUT=$(last -n 10 -F -w 2>/dev/null | grep -vE '^(reboot|shutdown|wtmp|^$)' | head -n 5)
    if [ -n "$LAST_OUTPUT" ]; then
        printf "\033[2m%-10s %-10s %-20s %-25s %s\033[0m\n" "USER" "TTY" "FROM" "LOGIN TIME" "STATUS"
        echo "$LAST_OUTPUT" | awk '{
            if ($0 ~ /still logged in/) {
                status_color = "\033[38;5;114m";
            } else {
                status_color = "\033[38;5;240m";
            }
            user = $1; tty = $2; from = $3;
            if (from == ":0" || from == "console") from = "(local)";
            login = $4" "$5" "$6" "$7;
            status = "";
            for (i = 8; i <= NF; i++) status = status " " $i;
            sub(/^ /, "", status);
            printf "%-10s %-10s %-20s %-25s %s%s\033[0m\n", user, tty, from, login, status_color, status;
        }'
    else
        echo -e "\033[2m# No login history available.\033[0m"
    fi
else
    echo -e "\033[2m# /var/log/wtmp is empty — logins are not being recorded.\033[0m"
fi
echo ""

# ==========================================
# FOOTER
# ==========================================
echo -e "\033[2m# compare load with core count: nproc\033[0m"
echo -e "\033[2m# low available + busy swap = memory pressure\033[0m"
echo -e "\033[2m# sparkline history stored at: ~/.beautiful_diag_history\033[0m"
