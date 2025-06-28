#!/bin/bash

# Function to calculate broadcast address
calculate_broadcast() {
    local ip_cidr=$1
    IFS='/' read -r ip prefix <<< "$ip_cidr"
    IFS='.' read -r a b c d <<< "$ip"
    
    case $prefix in
        8)  echo "$a.255.255.255" ;;
        16) echo "$a.$b.255.255" ;;
        24) echo "$a.$b.$c.255" ;;
        *)
            # For non-standard prefixes, calculate properly
            mask=$((0xffffffff << (32 - prefix) & 0xffffffff))
            o1=$(( (mask >> 24) & 0xff ))
            o2=$(( (mask >> 16) & 0xff ))
            o3=$(( (mask >> 8)  & 0xff ))
            o4=$(( mask & 0xff ))
            
            ba=$(( a | (255 ^ o1) ))
            bb=$(( b | (255 ^ o2) ))
            bc=$(( c | (255 ^ o3) ))
            bd=$(( d | (255 ^ o4) ))
            
            echo "$ba.$bb.$bc.$bd"
            ;;
    esac
}

# Function to display interface information
show_interfaces() {
    # Table header
    printf "+------------+-------------------+------------------+------------------------------------+------------------+\n"
    printf "| %-10s | %-17s | %-16s | %-34s | %-16s |\n" \
           "Interface" "MAC Address" "IPv4 Address" "IPv6 Address" "Broadcast"
    printf "+------------+-------------------+------------------+------------------------------------+------------------+\n"
    
    # Process each interface
    ip -o link show | awk '$2 != "lo:" {print substr($2, 1, length($2)-1)}' | while read -r iface; do
        # Get MAC address (only once per interface)
        mac=$(cat /sys/class/net/"$iface"/address 2>/dev/null || echo "N/A")
        first_row=true
        
        # Get all IPv4 addresses
        ipv4_list=$(ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{print $4}' | tr '\n' '|')
        
        # Get all IPv6 addresses (global first, then link-local)
        ipv6_list=$(ip -o -6 addr show dev "$iface" 2>/dev/null | awk '
            $4 ~ /^fe80::/ {link_local = link_local "|" $4; next}
            {print $4}
            END {if (link_local) print substr(link_local, 2)}
        ' | tr '\n' '|')
        
        # If no addresses at all
        if [ -z "$ipv4_list" ] && [ -z "$ipv6_list" ]; then
            printf "| %-10s | %-17s | %-16s | %-34s | %-16s |\n" \
                   "$iface" "$mac" "N/A" "N/A" "N/A"
            continue
        fi
        
        # Split into arrays
        IFS='|' read -ra ipv4_addrs <<< "$ipv4_list"
        IFS='|' read -ra ipv6_addrs <<< "$ipv6_list"
        
        # Determine max number of rows needed
        max_rows=$(( ${#ipv4_addrs[@]} > ${#ipv6_addrs[@]} ? ${#ipv4_addrs[@]} : ${#ipv6_addrs[@]} ))
        
        # Print each address pair
        for (( i=0; i<max_rows; i++ )); do
            ipv4_info="${ipv4_addrs[$i]:-}"
            ipv6_info="${ipv6_addrs[$i]:-}"
            
            [ -z "$ipv4_info" ] && ipv4_info="N/A"
            [ -z "$ipv6_info" ] && ipv6_info="N/A"
            
            # Calculate broadcast for IPv4
            if [ "$ipv4_info" != "N/A" ]; then
                broadcast=$(calculate_broadcast "$ipv4_info")
            else
                broadcast="N/A"
            fi
            
            # Only show interface name and MAC on first row
            if [ "$first_row" = true ]; then
                printf "| %-10s | %-17s | %-16s | %-34s | %-16s |\n" \
                       "$iface" "$mac" "$ipv4_info" "$ipv6_info" "$broadcast"
                first_row=false
            else
                printf "| %-10s | %-17s | %-16s | %-34s | %-16s |\n" \
                       "" "" "$ipv4_info" "$ipv6_info" "$broadcast"
            fi
        done
    done
    
    # Table footer
    printf "+------------+-------------------+------------------+------------------------------------+------------------+\n"

    echo ""
    ip route
    
    # Legend
#    echo ""
#    echo "Legend:"
#    echo "- Interface: Network interface name (shown only once per interface)"
#    echo "- MAC Address: Hardware address (shown only once per interface)"
#    echo "- IPv4 Address: All IPv4 addresses (one per row, includes subnet mask)"
#    echo "- IPv6 Address: All IPv6 addresses (global preferred, one per row)"
#    echo "- Broadcast: Calculated IPv4 broadcast address (N/A for IPv6)"
}

# Execute the function
show_interfaces
