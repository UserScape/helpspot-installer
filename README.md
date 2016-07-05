

<h1 style="line-height:62px;"><img src="https://www.helpspot.com/img/logo.png" alt="HelpSpot logo" height="62" width="171" style="float: left; margin-right: 20px;"> Installer</h1>

An installation script for GNU/Linux servers.

Tested on:

1. CentOS 7
2. RedHat 7
3. Debian 8
4. Ubuntu 14.04

<!--
Notes:

RedHat/CentOS 6 fairly common, but they need php 5.4 and mysql 5.5 minimum.
That will need documentation to note that.
-->

## How to Use:

Here's how to use this script.

### 1. Preparation

Your server must already have:

1. A web server (e.g. Apache or Nginx)
2. PHP 5.4+
3. HelpSpot license file much be present on the server file system. Usually named `license.txt`.
4. Create a database in MySQL with the following statement (adjust the database name as needed):

```sql
CREATE DATABASE IF NOT EXISTS helpspot_db 
    CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

You may wish to create a MySQL user specifically for HelpSpot as well.

```sql
CREATE USER 'helpspot_user'@'localhost' IDENTIFIED BY 'some_secure_password';
GRANT ALL PRIVILEGES on helpspot_db.* TO 'helpspot_user'@'localhost';
```

**Useful Tools:**

Two scripts are available to help setup a ***new*** server for Debian/Ubuntu or RedHat/CentOS servers. You can run these scripts directly on a new server, or use them as a reference on setting up a new server.

1. Debian/Ubuntu: [server_deb.sh](https://install.helpspot.com/server_deb.sh)
2. RedHat/CentOS: [server_rpm.sh](https://install.helpspot.com/server_rpm.sh)

### 2. Download Script

You can download the script to your local server:

```bash
curl -sL -o install.sh https://install.helpspot.com/install.sh
```

You'll then have an `install.sh` file ready to use! You can verify it's authenticy as it should match the following md5 checksum: `{{md5checksum}}`.

To check that it matches, run the following on your installed script (here we assume it's name `install.sh`):

```bash
# Should be {{md5checksum}}
md5 < install.sh
```

### 3. Install:

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

## Issues

#### Re-Trying the Install Script

If the script fails due to providing incorrect information at a prompt, you may need to clean up the helpspot installation directory (e.g. `rm -r /var/www/helpspot`) before attempting the install script again.

This script does not over-write files existing in the install location.

#### Other Issues

If you run into any issues, [contact HelpSpot Customer Support](https://support.helpspot.com/index.php?pg=request).
