#!/bin/bash

# Script to fix duplicate MOTD output on openSUSE
# This disables system motd.d execution that conflicts with our MOTD

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

echo -e "${GREEN}openSUSE MOTD Duplicate Output Fix${NC}"
echo "===================================="

# Check for pam_motd configurations that might execute scripts in /etc/motd.d
echo -e "\n${YELLOW}Checking for conflicting PAM configurations...${NC}"

PAM_FILES="/etc/pam.d/common-session /etc/pam.d/sshd /etc/pam.d/login"
FOUND_CONFLICT=0

for pam_file in $PAM_FILES; do
    if [ -f "$pam_file" ]; then
        if grep -q "pam_motd.so.*motd.d" "$pam_file"; then
            echo -e "${YELLOW}Found motd.d reference in $pam_file${NC}"
            FOUND_CONFLICT=1
            
            # Backup the file
            cp "$pam_file" "${pam_file}.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Comment out lines that reference motd.d
            sed -i 's/^\(.*pam_motd.so.*motd.d.*\)$/#\1 # Disabled by suse-motd/' "$pam_file"
            
            echo -e "${GREEN}✓ Disabled motd.d execution in $pam_file${NC}"
        fi
    fi
done

if [ $FOUND_CONFLICT -eq 0 ]; then
    echo -e "${GREEN}No conflicting PAM configurations found${NC}"
else
    echo -e "\n${GREEN}✓ Fixed duplicate output issue${NC}"
    echo -e "${YELLOW}PAM configurations have been backed up with timestamp${NC}"
fi

# Also check if there are any executable scripts in /etc/motd.d/
if [ -d "/etc/motd.d" ]; then
    EXEC_SCRIPTS=$(find /etc/motd.d -type f -executable 2>/dev/null)
    if [ ! -z "$EXEC_SCRIPTS" ]; then
        echo -e "\n${YELLOW}Found executable scripts in /etc/motd.d/:${NC}"
        echo "$EXEC_SCRIPTS"
        echo -e "${YELLOW}These might cause duplicate output. Consider removing or making them non-executable.${NC}"
    fi
fi

echo -e "\n${GREEN}Fix complete!${NC}"
echo "Please log out and back in to test the changes."