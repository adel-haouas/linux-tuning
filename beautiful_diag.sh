#!/bin/bash

# ======================================================================
# BEAUTIFUL DIAGNOSTICS SCRIPT (V6.5 — ADAPTIVE LAYOUT)
# chmod +x beautiful_diag.sh
# echo "alias diag='~/beautiful_diag.sh'" >> .bashrc; source .bashrc
# ======================================================================

BAR_LENGTH=30
COL_WIDTH=100
SPARK_COLS=20
SEPARATOR=" ⁞⁞ "
SEP_COLOR="122"

BOLD='\033[1m'
RESET='\033[0m'

# ==========================================
# TERMINAL WIDTH DETECTION & LAYOUT MODE
# ==========================================
# Determine terminal width using the most reliable method available
if [ -n "$BEAUTIFUL_DIAG_FORCE_MODE" ]; then
    case "$BEAUTIFUL_DIAG_FORCE_MODE" in
        single) ONE_COL_MODE=1 ;;
        dual)   ONE_COL_MODE=0 ;;
        *)      ONE_COL_MODE=0 ;;
    esac
else
    TERM_WIDTH=$(tput cols 2>/dev/null)
    if [ -z "$TERM_WIDTH" ] || [ "$TERM_WIDTH" -lt 1 ] 2>/dev/null; then
        TERM_WIDTH=$(stty size 2>/dev/null | awk '{print $2}')
    fi
    if [ -z "$TERM_WIDTH" ] || [ "$TERM_WIDTH" -lt 1 ] 2>/dev/null; then
        TERM_WIDTH="${COLUMNS:-80}"
    fi

    if [ "$TERM_WIDTH" -lt 180 ]; then
        ONE_COL_MODE=1
    else
        ONE_COL_MODE=0
    fi
fi

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
# SPARKLINE HELPER — LOAD
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

# ==========================================
# SPARKLINE HELPER — PER-NIC THROUGHPUT
# ==========================================
render_nic_sparkline() {
    local iface="$1"
    local rx="$2"
    local tx="$3"
    local history_file="$HOME/.beautiful_diag_net_history"
    local max_samples=$SPARK_COLS

    echo "$(date +%s) $iface $rx $tx" >> "$history_file"

    if [ $(wc -l < "$history_file") -gt 500 ]; then
        tail -n 500 "$history_file" > "${history_file}.tmp" && mv "${history_file}.tmp" "$history_file"
    fi

    awk -v ifc="$iface" -v max_samples="$max_samples" '
    function short(bytes,    units, i, size) {
        split("B K M G T", units, " ");
        size = bytes;
        i = 1;
        while (size >= 1024 && i < 5) { size /= 1024; i++; }
        if (i == 1) return sprintf("%dB", size);
        if (size < 10) return sprintf("%.1f%s", size, units[i]);
        return sprintf("%.0f%s", size, units[i]);
    }
    BEGIN {
        split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", blocks, " ");
        n = 0;
    }
    $2 == ifc {
        n++;
        rx[n] = $3 + 0;
        tx[n] = $4 + 0;
    }
    END {
        if (n > max_samples) {
            start = n - max_samples + 1;
        } else {
            start = 1;
        }
        count = n - start + 1;

        if (count < 2) {
            printf "\033[2m(need 2+ samples)\033[0m";
            exit;
        }

        samples = count - 1;
        max = 0;
        min = 99999999999;
        for (i = start + 1; i <= n; i++) {
            drx = rx[i] - rx[i-1];
            dtx = tx[i] - tx[i-1];
            if (drx < 0) drx = 0;
            if (dtx < 0) dtx = 0;
            delta[i] = drx + dtx;
            if (delta[i] > max) max = delta[i];
            if (delta[i] < min) min = delta[i];
        }
        if (max < 1) max = 1;

        log_max = log(max + 1);
        printf "\033[38;5;122m";
        for (i = start + 1; i <= n; i++) {
            idx = int((log(delta[i] + 1) / log_max) * 7) + 1;
            if (idx < 1) idx = 1;
            if (idx > 8) idx = 8;
            printf "%s", blocks[idx];
        }
        printf "\033[0m";

        if (samples < max_samples) {
            printf " \033[2m[%d/%d] %s…%s\033[0m", samples, max_samples, short(min), short(max);
        } else {
            printf " \033[2m%s…%s\033[0m", short(min), short(max);
        }
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

if [ -f /etc/debian_version ]; then
    DEB_VER=$(cat /etc/debian_version | tr -d '\n\r' | tr -d ' ')
    if echo "$DEB_VER" | grep -qE '^[0-9]+\.[0-9]+$'; then
        OS_NAME="${OS_NAME} [version ${DEB_VER}]"
    fi
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

MOUNTS=()
for m in "/" "/boot" "/data"; do
    if mountpoint -q "$m" 2>/dev/null || df "$m" >/dev/null 2>&1; then
        MOUNTS+=("$m")
    fi
done

MAX_FS_LEN=10
for m in "${MOUNTS[@]}"; do
    fs=$(df -h "$m" | awk 'NR==2 {print $1}')
    len=${#fs}
    if [ "$len" -gt "$MAX_FS_LEN" ]; then
        MAX_FS_LEN=$len
    fi
done

FS_WIDTH=$((MAX_FS_LEN + 2))

printf "\033[2m%-${FS_WIDTH}s %5s %5s %5s %4s %s\033[0m\n" "Filesystem" "Size" "Used" "Avail" "Use%" "Mounted on"

for m in "${MOUNTS[@]}"; do
    fs=$(df -h "$m" | awk 'NR==2 {print $1}')
    total=$(df -h "$m" | awk 'NR==2 {print $2}')
    used=$(df -h "$m" | awk 'NR==2 {print $3}')
    avail=$(df -h "$m" | awk 'NR==2 {print $4}')
    percent=$(df -h "$m" | awk 'NR==2 {print $5}' | tr -d '%')

    printf "%-${FS_WIDTH}s %5s %5s %5s %3s%% %s\n" "$fs" "$total" "$used" "$avail" "$percent" "$m"
done
echo ""

BAR_LINE=""
for m in "${MOUNTS[@]}"; do
    percent=$(df -h "$m" | awk 'NR==2 {print $5}' | tr -d '%')
    label=$(printf "%-5s" "$m")
    BAR=$(draw_bar_str "$label" "$percent")
    if [ -z "$BAR_LINE" ]; then
        BAR_LINE="$BAR"
    else
        BAR_LINE="${BAR_LINE}   ${BAR}"
    fi
done
printf "%b\n" "$BAR_LINE"
echo ""

# ==========================================
# NETWORK STATS — ADAPTIVE LAYOUT
# ==========================================
header "Network"

NIC_LINES=()

while IFS= read -r iface; do
    [ -z "$iface" ] && continue

    read -r RX_BYTES TX_BYTES < <(awk -v ifc="$iface" '
        NR>2 {
            gsub(/^[ \t]+/, "");
            split($0, arr, ":");
            name = arr[1];
            gsub(/^[ \t]+/, "", name);
            if (name == ifc) {
                split(arr[2], s, " ");
                n = 0;
                for (i in s) if (s[i] != "") { n++; vals[n] = s[i]; }
                printf "%s %s\n", vals[1], vals[9];
                exit;
            }
        }' /proc/net/dev)

    [ -z "$RX_BYTES" ] && continue

    RX_H=$(awk -v b="$RX_BYTES" 'BEGIN {
        split("B KiB MiB GiB TiB", u, " ");
        s = b; i = 1;
        while (s >= 1024 && i < 5) { s /= 1024; i++; }
        if (i == 1) printf "%d %s", s, u[i]; else printf "%.2f %s", s, u[i];
    }')
    TX_H=$(awk -v b="$TX_BYTES" 'BEGIN {
        split("B KiB MiB GiB TiB", u, " ");
        s = b; i = 1;
        while (s >= 1024 && i < 5) { s /= 1024; i++; }
        if (i == 1) printf "%d %s", s, u[i]; else printf "%.2f %s", s, u[i];
    }')

    STATE=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null || echo "unknown")
    case "$STATE" in
        up)      COLOR="114" ;;
        down)    COLOR="203" ;;
        dormant) COLOR="214" ;;
        *)       COLOR="240" ;;
    esac
    STATE_UP=$(echo "$STATE" | tr 'a-z' 'A-Z')

    SPARK=$(render_nic_sparkline "$iface" "$RX_BYTES" "$TX_BYTES")

    NIC_LINE=$(printf "  \033[38;5;255m%-8s\033[0m  \033[38;5;%sm[%-5s]\033[0m  RX: %-10s  TX: %-10s %b" \
        "$iface" "$COLOR" "$STATE_UP" "$RX_H" "$TX_H" "$SPARK")

    NIC_LINES+=("$NIC_LINE")
done < <(awk 'NR>2 {
    gsub(/^[ \t]+/, "");
    split($0, arr, ":");
    iface = arr[1];
    gsub(/^[ \t]+/, "", iface);
    if (iface == "lo" || iface ~ /^tun/) next;

    state_file = "/sys/class/net/" iface "/operstate";
    state = "unknown";
    if ((getline st < state_file) > 0) { state = st; close(state_file); }

    stats = arr[2];
    split(stats, s, " ");
    n = 0;
    for (i in s) if (s[i] != "") { n++; vals[n] = s[i]; }
    if (vals[1] < 1048576 && vals[9] < 1048576 && state != "down") next;
    print iface;
}' /proc/net/dev)

NIC_COUNT=${#NIC_LINES[@]}

if [ "$NIC_COUNT" -eq 0 ]; then
    echo -e "\033[2m# All interfaces have less than 1 MiB of traffic.\033[0m"
else
    if [ "$ONE_COL_MODE" -eq 1 ]; then
        # Single-column mode: 1 NIC per row
        for i in $(seq 0 $((NIC_COUNT - 1))); do
            printf "%b\n" "${NIC_LINES[$i]}"
        done
    else
        # Dual-column mode: 2 NICs per row
        SEP_COLORED="\033[38;5;${SEP_COLOR}m${SEPARATOR}\033[0m"

        i=0
        while [ $i -lt $NIC_COUNT ]; do
            left="${NIC_LINES[$i]}"
            right=""
            if [ $((i + 1)) -lt $NIC_COUNT ]; then
                right="${NIC_LINES[$((i + 1))]}"
            fi
            if [ -n "$right" ]; then
                left_plain=$(printf "%b" "$left" | strip_ansi)
                left_len=${#left_plain}
                pad=$(( COL_WIDTH - left_len ))
                if [ "$pad" -lt 1 ]; then pad=1; fi
                printf "%b%${pad}s%b%b\n" "$left" "" "$SEP_COLORED" "$right"
            else
                printf "%b\n" "$left"
            fi
            i=$((i + 2))
        done
    fi
fi
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
echo -e "\033[2m# sparkline history: ~/.beautiful_diag_history (load), ~/.beautiful_diag_net_history (net)\033[0m"
echo -e "\033[2m# network sparkline uses log scale (see render_nic_sparkline)\033[0m"
if [ "$ONE_COL_MODE" -eq 1 ]; then
    echo -e "\033[2m# layout: single-column (terminal < 180 cols)\033[0m"
else
    echo -e "\033[2m# layout: dual-column (terminal >= 180 cols)\033[0m"
fi
