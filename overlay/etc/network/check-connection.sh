#!/bin/bash

# Check network connection status and remove default routes for inactive interfaces

# Function to check if an interface is active
is_interface_active() {
    local interface=$1
    # Check if interface exists and has an IP address
    if ip addr show $interface 2>/dev/null | grep -q "inet "; then
        # Try to ping a reliable server via specific interface
        if ping -c 1 -W 2 -I $interface 8.8.8.8 > /dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Get all interfaces with default routes
interfaces=$(ip route show default | awk '{print $5}' | sort -u)

for interface in $interfaces; do
    if ! is_interface_active $interface; then
        # Remove default route for inactive interface
        ip route del default dev $interface 2>/dev/null
        echo "Removed default route for inactive interface: $interface"
    fi
done

# Ensure only the highest priority active interface has default route
active_interfaces=()
for interface in $interfaces; do
    if is_interface_active $interface; then
        active_interfaces+=($interface)
    fi
done

if [ ${#active_interfaces[@]} -gt 1 ]; then
    # Get metrics for active interfaces
    declare -A metrics
    for interface in "${active_interfaces[@]}"; do
        metric=$(ip route show default dev $interface | awk '{print $7}' | grep -o '[0-9]*')
        metrics[$interface]=$metric
    done

    # Sort interfaces by metric (ascending)
    sorted=($(for iface in "${!metrics[@]}"; do echo "$iface ${metrics[$iface]}"; done | sort -k2 -n | awk '{print $1}'))

    # Keep only the first (highest priority) interface
    primary_interface=${sorted[0]}

    # Remove default routes for other active interfaces
    for interface in "${sorted[@]:1}"; do
        ip route del default dev $interface 2>/dev/null
        echo "Removed default route for lower priority interface: $interface"
    done
fi
