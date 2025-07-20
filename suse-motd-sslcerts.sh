#!/bin/bash

# SSL Certificate Status Script for MOTD
# Shows Certbot SSL certificate information

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "  SSL Certs: Certbot not installed"
    exit 0
fi

# Check if running as root (needed to access certbot certificates)
if [ "$EUID" -ne 0 ]; then 
    echo "  SSL Certs: Unable to check (requires root)"
    exit 0
fi

# Get certificate information
cert_info=$(certbot certificates 2>/dev/null)

if [ -z "$cert_info" ] || echo "$cert_info" | grep -q "No certificates found"; then
    echo "  SSL Certs: No certificates found"
    exit 0
fi

# Parse certificate information
echo "  SSL Certificates:"

# Process each certificate block
while IFS= read -r line; do
    if [[ $line =~ "Certificate Name:" ]]; then
        cert_name=$(echo "$line" | awk -F': ' '{print $2}')
    elif [[ $line =~ "Domains:" ]]; then
        domains=$(echo "$line" | awk -F': ' '{print $2}')
    elif [[ $line =~ "Expiry Date:" ]]; then
        expiry=$(echo "$line" | awk -F': ' '{print $2}' | awk '{print $1, $2, $3}')
        # Calculate days until expiry
        expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null)
        current_epoch=$(date +%s)
        if [ ! -z "$expiry_epoch" ]; then
            days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))
            
            # Color code based on days left
            if [ $days_left -le 7 ]; then
                color="\e[31m"  # Red for urgent
            elif [ $days_left -le 30 ]; then
                color="\e[33m"  # Yellow for warning
            else
                color="\e[32m"  # Green for good
            fi
        else
            days_left="?"
            color="\e[33m"
        fi
    elif [[ $line =~ "Key Type:" ]]; then
        key_info=$(echo "$line" | awk -F': ' '{print $2}')
        # Output the certificate info
        echo -e "  $domains: ${color}● $days_left days\e[0m ($key_info)"
    fi
done <<< "$cert_info"