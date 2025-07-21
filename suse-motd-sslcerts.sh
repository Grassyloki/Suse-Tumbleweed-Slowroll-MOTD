#!/bin/bash

# SSL Certificate Status Script for MOTD - Optimized version
# Shows Certbot SSL certificate information

# Check if running as root (needed to access certificates)
if [ "$EUID" -ne 0 ]; then 
    echo "  SSL Certs: Unable to check (requires root)"
    exit 0
fi

# Check if Let's Encrypt directory exists
if [ ! -d "/etc/letsencrypt/live" ]; then
    echo "  SSL Certs: No certificates found"
    exit 0
fi

# Get list of certificate directories
cert_dirs=$(find /etc/letsencrypt/live -maxdepth 1 -type d ! -path /etc/letsencrypt/live 2>/dev/null)

if [ -z "$cert_dirs" ]; then
    echo "  SSL Certs: No certificates found"
    exit 0
fi

echo "  SSL Certificates:"

# Process each certificate
for cert_dir in $cert_dirs; do
    domain=$(basename "$cert_dir")
    cert_file="$cert_dir/cert.pem"
    
    if [ -f "$cert_file" ]; then
        # Get expiry date and key info using openssl (much faster than certbot)
        expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" 2>/dev/null | cut -d= -f2)
        
        if [ ! -z "$expiry_date" ]; then
            # Convert to epoch for calculation
            expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null)
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
                
                # Get key type and size (faster method)
                key_info=$(openssl x509 -noout -text -in "$cert_file" 2>/dev/null | grep "Public Key Algorithm:" | sed 's/.*: //')
                if [ -z "$key_info" ]; then
                    key_info="Unknown"
                fi
                
                echo -e "  $domain: ${color}● $days_left days\e[0m ($key_info)"
            fi
        fi
    fi
done