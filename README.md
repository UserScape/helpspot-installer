

<h1 style="line-height:62px;"><img src="https://www.helpspot.com/img/logo.png" alt="HelpSpot logo" height="62" width="171" style="float: left; margin-right: 20px;"> Linux Installer</h1>

An HelpSpot installation script for GNU/Linux servers.

## How to Use:

Here's how to use this script.

### 1. Preparation

Your server must already have:

1. A web server (e.g. Apache or Nginx)
2. PHP 5.6, 7.0+
3. HelpSpot license file much be present on the server file system. Usually named `license.txt`.
4. MySQL 5.6+ with a database created using the following statement (adjust the database name as needed):

```sql
CREATE DATABASE IF NOT EXISTS helpspot_db 
    CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

You may wish to create a MySQL user specifically for HelpSpot as well.

```sql
CREATE USER 'helpspot_user'@'localhost' IDENTIFIED BY 'some_secure_password';
GRANT ALL PRIVILEGES on helpspot_db.* TO 'helpspot_user'@'localhost';
```

> **Useful Tools:**
>
> Two optional scripts are available to help install Nginx, PHP and MySQL on a ***new*** server for Debian/Ubuntu or RedHat/CentOS servers. You can run these scripts directly on a new server, or use them as a reference on setting up a new server. However please review them to ensure they're correct for your version and flavor of GNU/Linux before running them.
>
> 1. Debian/Ubuntu: [server_deb.sh](https://install.helpspot.com/server_deb.sh)
> 2. RedHat/CentOS: [server_rpm.sh](https://install.helpspot.com/server_rpm.sh)

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

# Use md5sum if no "md5" found
md5sum < install.sh
```

### 3. Install:

Once the `install.sh` script is present on the web server, you can begin the installation process:

```bash
# Requires root or sudo user to run

# If you've placed your HelpSpot license file in this same directory
# and named it license.txt just run this command.
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

## Compatibility

This installation script has been tested on:

1. ![centos](https://s3.amazonaws.com/helpspot-assets/os-centos.png) CentOS 7
2. ![centos](https://s3.amazonaws.com/helpspot-assets/os-centos.png) CentOS 6<sup>†</sup>
3. ![redhat](https://s3.amazonaws.com/helpspot-assets/os-rh.png) RedHat 7
4. ![redhat](https://s3.amazonaws.com/helpspot-assets/os-rh.png) RedHat 6<sup>†</sup>
5. ![debian](https://s3.amazonaws.com/helpspot-assets/os-debian.png) Debian 8
6. ![ubuntu](https://s3.amazonaws.com/helpspot-assets/os-ubuntu.png) Ubuntu 14.04
7. ![ubuntu](https://s3.amazonaws.com/helpspot-assets/os-ubuntu.png) Ubuntu 16.04

<sup>†</sup> Requires non-standard packages to install [MySQL 5.5+](http://www.tecmint.com/install-latest-mysql-on-rhel-centos-and-fedora/) and [PHP 5.6+](https://webtatic.com/packages/php56/)

## Issues

#### Re-Trying the Install Script

If the script fails due to providing incorrect information at a prompt, you will need to clean up the helpspot installation directory (e.g. `rm -r /var/www/helpspot`) and reset the database (drop all tables, or delete and re-create the database) before attempting the install script again.

This script does **not** over-write files existing in the install location.

#### Other Issues

If you run into any issues, [contact HelpSpot Customer Support](https://support.helpspot.com/index.php?pg=request).


## Contributions

Contributions are welcome! You can find the source for [HelpSpot Installer on GitHub](https://github.com/userscape/helpspot-installer).
