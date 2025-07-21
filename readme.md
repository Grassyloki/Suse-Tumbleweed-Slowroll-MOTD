# openSUSE Tumbleweed Slowroll MOTD

A dynamic Message of the Day (MOTD) generator for openSUSE Tumbleweed Slowroll systems, providing an informative and visually appealing login banner with system statistics.

## Features

- Custom openSUSE ASCII art logo
- Real-time system information display
- Service status monitoring
- SSL certificate expiration tracking
- BTRFS snapshot information
- Network interface details
- Package update notifications via zypper

## Preview

```
                     ...................
                 ...........................
              ........                .........
           .......                         ......
         ......                              ......
        .....                                  ......
      .....                                      .....
     .....                 ......                  ....
    .....              ...............              ....
    ....            .........   ........             ....
   ....            .....            ......            ....
  ....            ....                .....           ....
  ....           ....                   ....           ....
  ....          ....                    ....           ....     ......   ..                                      ..  ..
  ...           ....                     ....          ....    ..        ..   ....   ..   ..   .  .....  ....    ..  ..
  ...           ....                     ....          ....     .....    ..  ..   ..  .. ...  ..  ..    ..   ..  ..  ..
  ....          ....                     ...           ....         ...  .. ..    ..  .. . .. .   ..   ..    ..  ..  ..
  ....           ....                   ....           ....          ..  ..  .    ..   ...  ...   ..    .    ..  ..  ..
  .....           ......                ....          ....     .......   ..   .....    ..   ...   ..     .....   ..  ..
   ....             ........           ....           ....
   ......              .....          ....           ....
    ......                          .....           ....
     .......                      ......           ....
      .........                .......            ....
        ............      ..........            .....
         ........................             .....
           ......  ........                .......
             ........                  ........
                .............................
                    .....................
                            ....

---------------------------------------------------------------
   Good Evening! You're Logged Into YourHostname!
---------------------------------------------------------------
    KERNEL : 6.15.4-1-default x86_64
       CPU : 4 x Intel(R) Xeon(R) Gold 6263CY CPU @ 2.60GHz
    MEMORY : 638 MB used of 7942 MB - 8.04% (Used)
 ROOT DISK : 7.6G used of 127G | 118G Free (7%)
  SNAPSHOT : Last: 2025-07-20 19:38:21
 IPv4 ADDR : 192.168.1.100/24
 IPv6 ADDR : fe80::346e:819d:a83:1de6/64
---------------------------------------------------------------
  LOAD AVG : 0.25, 0.09, 0.02
    UPTIME : 0 days 0 hours 20 minutes 23 seconds
 PROCESSES : There are currently 182 processes running
    ZYPPER : 5 packages can be updated
     USERS : 1 users logged in
---------------------------------------------------------------
   OpenSSH-Server: ● active
  Nginx Reverse Proxy: ● active
---------------------------------------------------------------
   SSL Certificates:
  example.com: ● 70 days (id-ecPublicKey)
  subdomain.example.com: ● 45 days (RSA)
```

## Installation

### Quick Install

```bash
git clone https://github.com/Grassyloki/Suse-Tumbleweed-Slowroll-MOTD.git
cd Suse-Tumbleweed-Slowroll-MOTD
sudo ./suse-motd-install.sh
```

### What the installer does:

1. Copies the main MOTD script to `/bin/generate_motd.sh`
2. Installs supporting scripts to `/usr/local/share/suse-motd/`
3. Updates PAM configuration to execute the script on login
4. Creates automatic backups of your PAM configuration
5. Generates an initial MOTD

## Configuration

### Customize Monitored Services

Edit `/usr/local/share/suse-motd/suse-motd-services.sh` to add or remove services:

```bash
declare -a services=(
"sshd"
"nginx"
"mariadb"
"docker"
)
declare -a serviceName=(
"OpenSSH-Server"
"Nginx Reverse Proxy"
"MariaDB Database"
"Docker Engine"
)
```

### SSL Certificate Monitoring

The SSL certificate monitor automatically detects certificates in `/etc/letsencrypt/live/` and displays:
- Domain name
- Days until expiration (color-coded)
- Key type (RSA, ECDSA, etc.)

**Note:** Root access is required to read certificate information.

## Uninstallation

To completely remove the MOTD system:

```bash
sudo ./suse-motd-uninstall.sh
```

This will:
- Remove all installed scripts
- Revert PAM configuration changes
- Clear the MOTD file
- Preserve configuration backups for safety

## Troubleshooting

### Duplicate Output

If you see script content or duplicate output in your MOTD:

```bash
sudo ./suse-motd-fix-duplicate.sh
```

This disables conflicting system motd.d execution.

### Manual PAM Configuration

If automatic PAM configuration fails, add this line to `/etc/pam.d/common-session`:

```
session optional   pam_exec.so          /bin/generate_motd.sh
```

Add it after the `pam_limits.so` line.

## File Structure

```
├── suse-motd-main.sh         # Main MOTD generation script
├── suse-motd-services.sh     # Service status monitoring
├── suse-motd-sslcerts.sh     # SSL certificate monitoring
├── suse-motd-install.sh      # Installation script
├── suse-motd-uninstall.sh    # Uninstallation script
├── suse-motd-fix-duplicate.sh # Fix for duplicate output issues
└── README.md                 # This file
```

## Requirements

- openSUSE Tumbleweed or Slowroll
- Root access for installation
- systemd (for service monitoring)
- OpenSSL (for certificate checking)
- Standard GNU/Linux utilities (awk, sed, grep, etc.)

## Credits

Based on the original Arch Linux MOTD by [/u/LookAtMyKeyboard](https://www.reddit.com/user/LookAtMyKeyboard)

Adapted for openSUSE Tumbleweed Slowroll with:
- BTRFS snapshot support
- Zypper package management integration
- openSUSE-specific optimizations

## License

This project is Licenced under the Apache 2.0 License

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

### Areas for contribution:
- Additional service templates
- Performance optimizations
- Support for more system information
- Improved BTRFS integration
- Theme customization options
