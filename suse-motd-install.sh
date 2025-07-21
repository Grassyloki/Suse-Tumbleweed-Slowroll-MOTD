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

# Create directory for MOTD scripts
echo -e "\n${YELLOW}Creating /usr/local/share/suse-motd directory...${NC}"
mkdir -p /usr/local/share/suse-motd

# Copy scripts
echo -e "${YELLOW}Installing MOTD scripts...${NC}"

# Main script
if [ -f "suse-motd-main.sh" ]; then
    cp suse-motd-main.sh /bin/generate_motd.sh
    chmod 0755 /bin/generate_motd.sh
    chown root:root /bin/generate_motd.sh
    echo -e "${GREEN}✓ Main MOTD script installed${NC}"
else
    echo -e "${RED}✗ suse-motd-main.sh not found in current directory${NC}"
    exit 1
fi

# Services script
if [ -f "suse-motd-services.sh" ]; then
    cp suse-motd-services.sh /usr/local/share/suse-motd/
    chmod 0755 /usr/local/share/suse-motd/suse-motd-services.sh
    chown root:root /usr/local/share/suse-motd/suse-motd-services.sh
    echo -e "${GREEN}✓ Services script installed${NC}"
else
    echo -e "${RED}✗ suse-motd-services.sh not found in current directory${NC}"
    exit 1
fi

# SSL Certs script
if [ -f "suse-motd-sslcerts.sh" ]; then
    cp suse-motd-sslcerts.sh /usr/local/share/suse-motd/
    chmod 0755 /usr/local/share/suse-motd/suse-motd-sslcerts.sh
    chown root:root /usr/local/share/suse-motd/suse-motd-sslcerts.sh
    echo -e "${GREEN}✓ SSL certificates script installed${NC}"
else
    echo -e "${RED}✗ suse-motd-sslcerts.sh not found in current directory${NC}"
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
        # Add the pam_exec line after pam_limits.so or at the beginning
        if grep -q "pam_limits.so" /etc/pam.d/common-session; then
            sed -i '/pam_limits.so/a session optional   pam_exec.so          /bin/generate_motd.sh' /etc/pam.d/common-session
        else
            # Add at the beginning of the file
            sed -i '1i session optional   pam_exec.so          /bin/generate_motd.sh' /etc/pam.d/common-session
        fi
        echo -e "${GREEN}✓ PAM configuration updated${NC}"
    fi
else
    echo -e "${YELLOW}Skipping PAM configuration update${NC}"
    echo -e "${YELLOW}To manually update, add this line to /etc/pam.d/common-session:${NC}"
    echo "session optional   pam_exec.so          /bin/generate_motd.sh"
    echo -e "${YELLOW}Add it after the pam_limits.so line${NC}"
fi

# Generate initial MOTD
echo -e "\n${YELLOW}Generating initial MOTD...${NC}"
/bin/generate_motd.sh
echo -e "${GREEN}✓ Initial MOTD generated${NC}"

# Customize services
echo -e "\n${YELLOW}Note: To customize monitored services, edit:${NC}"
echo "/usr/local/share/suse-motd/suse-motd-services.sh"
echo "Add or remove services from the 'services' and 'serviceName' arrays."

echo -e "\n${GREEN}Installation complete!${NC}"
echo "The MOTD will be displayed on your next login."
echo -e "\n${YELLOW}Backup of PAM configuration saved with timestamp${NC}"

# Clean up any old scripts in /etc/motd.d/
if [ -f "/etc/motd.d/suse-motd-services.sh" ] || [ -f "/etc/motd.d/suse-motd-sslcerts.sh" ]; then
    echo -e "\n${YELLOW}Cleaning up old scripts from /etc/motd.d/...${NC}"
    rm -f /etc/motd.d/suse-motd-services.sh /etc/motd.d/suse-motd-sslcerts.sh
    echo -e "${GREEN}✓ Old scripts removed${NC}"
fi

# Test the installation
echo -e "\n${YELLOW}Testing installation...${NC}"
if [ -x /bin/generate_motd.sh ] && [ -f /etc/motd ]; then
    echo -e "${GREEN}✓ Installation test passed${NC}"
    echo -e "\n${YELLOW}Note: If you see duplicate output or script content in your MOTD,${NC}"
    echo -e "${YELLOW}you may need to disable system motd.d execution by commenting out${NC}"
    echo -e "${YELLOW}any 'pam_motd.so' lines that reference '/etc/motd.d' in PAM configs.${NC}"
else
    echo -e "${RED}✗ Installation test failed${NC}"
    exit 1
fi