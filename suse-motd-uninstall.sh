#!/bin/bash

# Uninstallation script for openSUSE Tumbleweed Slowroll MOTD
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

echo -e "${GREEN}openSUSE Tumbleweed Slowroll MOTD Uninstallation Script${NC}"
echo "========================================================"

echo -e "${RED}WARNING: This will remove the MOTD scripts and revert PAM configuration${NC}"
echo -n "Do you want to continue? [y/N]: "
read -r response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Remove scripts
echo -e "\n${YELLOW}Removing MOTD scripts...${NC}"

if [ -f "/bin/generate_motd.sh" ]; then
    rm -f /bin/generate_motd.sh
    echo -e "${GREEN}✓ Main MOTD script removed${NC}"
else
    echo -e "${YELLOW}Main MOTD script not found${NC}"
fi

if [ -f "/usr/local/share/suse-motd/suse-motd-services.sh" ]; then
    rm -f /usr/local/share/suse-motd/suse-motd-services.sh
    echo -e "${GREEN}✓ Services script removed${NC}"
else
    echo -e "${YELLOW}Services script not found${NC}"
fi

if [ -f "/usr/local/share/suse-motd/suse-motd-sslcerts.sh" ]; then
    rm -f /usr/local/share/suse-motd/suse-motd-sslcerts.sh
    echo -e "${GREEN}✓ SSL certificates script removed${NC}"
else
    echo -e "${YELLOW}SSL certificates script not found${NC}"
fi

# Remove directory if empty
if [ -d "/usr/local/share/suse-motd" ] && [ -z "$(ls -A /usr/local/share/suse-motd)" ]; then
    rmdir /usr/local/share/suse-motd
    echo -e "${GREEN}✓ Empty suse-motd directory removed${NC}"
fi

# Revert PAM configuration
echo -e "\n${YELLOW}Reverting PAM configuration...${NC}"
if [ -f "/etc/pam.d/common-session" ]; then
    # Remove the pam_exec line for generate_motd.sh
    sed -i '/pam_exec.so.*generate_motd.sh/d' /etc/pam.d/common-session
    echo -e "${GREEN}✓ PAM configuration reverted${NC}"
else
    echo -e "${RED}✗ /etc/pam.d/common-session not found${NC}"
fi

# Clear the MOTD file
echo -e "\n${YELLOW}Clearing MOTD file...${NC}"
> /etc/motd
echo -e "${GREEN}✓ MOTD file cleared${NC}"

echo -e "\n${GREEN}Uninstallation complete!${NC}"
echo -e "${YELLOW}Note: PAM configuration backups were not removed.${NC}"
echo "They can be found in /etc/pam.d/ with .backup.* extension"