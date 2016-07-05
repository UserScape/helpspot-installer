# helpspot-installer

Customer Installer for HelpSpot

## How to Use:

### Prep:

1. Server must have a web server and php 5.4+ installed prior to running the instsallation script.
    - Scripts provided `server_deb.sh` and `server_rpm.sh` can help setup a FRESH (new) server for Debian/Ubuntu or RedHat/CentOS servers
2. HelpSpot license file much be present on the server file system. Usually named `license.txt`.
3. Create a database in MySQL with the following statement (adjust the database name as needed):

```sql
CREATE DATABASE IF NOT EXISTS helpspot_db 
       CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

> You may wish to create a user specifically for HelpSpot as well.

### Install:

Once the `install.sh` script is present on the web server, you can begin the installation process:

```bash
# Requires root or sudo user to run

# This installs license.txt is alongside install.sh,
#   within the same directory
sudo bash install.sh

# Or we can define the license file location
sudo bash install.sh --license=/tmp/license.txt
```

This will prompt for:

1. Where to install HelpSpot (e.g. `/var/www/helpspot`)
2. Database information (to configure HelpSpot's `config.php` file)
3. HelpSpot install details, including 
    - Admin user email/password
    - HelpSpot details (name, reply-to email)
    - HelpSpot Customer ID
    - Timezone (Includes auto-complete, but you can also [find valid timezones here](http://php.net/manual/en/timezones.php))

## TO DO:

Security:

Set location to get md5 hash of shell script to verify location if install directions end up being `curl [our cript url] | sudo bash`.
