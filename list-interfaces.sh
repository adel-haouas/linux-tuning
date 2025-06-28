#!/bin/bash

# Function to display separator line (now with 17-char middle column)
separator() {
    printf "+--------------+-------------------+--------------------------------+\n"
}

# Function to display network interfaces
show_interfaces() {
    # Table header
    separator
    printf "| %-12s | %-17s | %-30s |\n" "Name" "MAC address" "IP address"
    separator
    
    # Process each interface
    ip -o link show | awk '$2 != "lo:" {print substr($2, 1, length($2)-1)}' | while read -r iface; do
        # Get MAC address
        mac=$(cat /sys/class/net/"$iface"/address 2>/dev/null || echo "")
        
        # Get all IP addresses (IPv4 first, then IPv6)
        ip_list=$(ip -o addr show dev "$iface" 2>/dev/null | awk '{print $4}' | tr '\n' '|')
        
        # If no addresses
        if [ -z "$ip_list" ]; then
            printf "| %-12s | %-17s | %-30s |\n" "$iface" "$mac" "N/A"
            separator
            continue
        fi
        
        # Split into array
        IFS='|' read -ra ip_addrs <<< "$ip_list"
        
        # Print first row with interface name and MAC
        printf "| %-12s | %-17s | %-30s |\n" "$iface" "$mac" "${ip_addrs[0]}"
        
        # Print additional IPs without repeating name/MAC
        for (( i=1; i<${#ip_addrs[@]}; i++ )); do
            printf "| %-12s | %-17s | %-30s |\n" "" "" "${ip_addrs[$i]}"
        done
        
        separator
    done
}

show_routes() {
  ip route
}

show_interfaces
echo ""
show_routes
