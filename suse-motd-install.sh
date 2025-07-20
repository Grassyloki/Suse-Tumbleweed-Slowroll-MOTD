#!/bin/bash

# Installation script for openSUSE Tumbleweed Slowroll MOTD
# Must be run as root

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

echo -e "${GREEN}openSUSE Tumbleweed Slowroll MOTD Installation Script${NC}"
echo "======================================================"

# Create motd.d directory if it doesn't exist
echo -e "\n${YELLOW}Creating /etc/motd.d directory...${NC}"
mkdir -p /etc/motd.d

# Copy scripts
echo -e "${YELLOW}Installing MOTD scripts...${NC}"

# Main script
if [ -f "SuseMOTD.sh" ]; then
    cp SuseMOTD.sh /bin/generate_motd.sh
    chmod 0755 /bin/generate_motd.sh
    chown root:root /bin/generate_motd.sh
    echo -e "${GREEN}✓ Main MOTD script installed${NC}"
else
    echo -e "${RED}✗ SuseMOTD.sh not found in current directory${NC}"
    exit 1
fi

# Services script
if [ -f "Suse-MOTD-Services.sh" ]; then
    cp Suse-MOTD-Services.sh /etc/motd.d/
    chmod 0755 /etc/motd.d/Suse-MOTD-Services.sh
    chown root:root /etc/motd.d/Suse-MOTD-Services.sh
    echo -e "${GREEN}✓ Services script installed${NC}"
else
    echo -e "${RED}✗ Suse-MOTD-Services.sh not found in current directory${NC}"
    exit 1
fi

# SSL Certs script
if [ -f "Suse-MOTD-sslCerts.sh" ]; then
    cp Suse-MOTD-sslCerts.sh /etc/motd.d/
    chmod 0755 /etc/motd.d/Suse-MOTD-sslCerts.sh
    chown root:root /etc/motd.d/Suse-MOTD-sslCerts.sh
    echo -e "${GREEN}✓ SSL certificates script installed${NC}"
else
    echo -e "${RED}✗ Suse-MOTD-sslCerts.sh not found in current directory${NC}"
    exit 1
fi

# Backup PAM configuration
echo -e "\n${YELLOW}Backing up PAM configuration...${NC}"
if [ -f "/etc/pam.d/common-session" ]; then
    cp /etc/pam.d/common-session /etc/pam.d/common-session.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✓ PAM configuration backed up${NC}"
else
    echo -e "${RED}✗ /etc/pam.d/common-session not found${NC}"
    exit 1
fi

# Update PAM configuration
echo -e "\n${YELLOW}Updating PAM configuration...${NC}"
echo -e "${RED}WARNING: This will modify your PAM configuration!${NC}"
echo -e "Current PAM session configuration will be modified to execute the MOTD script."
echo -n "Do you want to continue? [y/N]: "
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Check if the line already exists
    if grep -q "pam_exec.so.*generate_motd.sh" /etc/pam.d/common-session; then
        echo -e "${YELLOW}PAM configuration already contains MOTD script${NC}"
    else
        # Add the pam_exec line before pam_motd
        sed -i '/pam_motd.so/i session    optional   pam_exec.so          /bin/generate_motd.sh' /etc/pam.d/common-session
        echo -e "${GREEN}✓ PAM configuration updated${NC}"
    fi
else
    echo -e "${YELLOW}Skipping PAM configuration update${NC}"
    echo -e "${YELLOW}To manually update, add this line to /etc/pam.d/common-session:${NC}"
    echo "session    optional   pam_exec.so          /bin/generate_motd.sh"
    echo -e "${YELLOW}Add it before the pam_motd.so line${NC}"
fi

# Generate initial MOTD
echo -e "\n${YELLOW}Generating initial MOTD...${NC}"
/bin/generate_motd.sh
echo -e "${GREEN}✓ Initial MOTD generated${NC}"

# Customize services
echo -e "\n${YELLOW}Note: To customize monitored services, edit:${NC}"
echo "/etc/motd.d/Suse-MOTD-Services.sh"
echo "Add or remove services from the 'services' and 'serviceName' arrays."

echo -e "\n${GREEN}Installation complete!${NC}"
echo "The MOTD will be displayed on your next login."
echo -e "\n${YELLOW}Backup of PAM configuration saved with timestamp${NC}"

# Test the installation
echo -e "\n${YELLOW}Testing installation...${NC}"
if [ -x /bin/generate_motd.sh ] && [ -f /etc/motd ]; then
    echo -e "${GREEN}✓ Installation test passed${NC}"
else
    echo -e "${RED}✗ Installation test failed${NC}"
    exit 1
fi