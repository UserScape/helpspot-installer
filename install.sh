#!/usr/bin/env bash

# Bail on first error
set -e




######################################################################
#
# Some Notes
#
######################################################################

# Most things here will need a centos/redhat vs debian/ubuntu
#  install paths
# We'll assume php and web server (apache or nginx) already setup





######################################################################
#
# UTILITY FUNCTIONS
#
######################################################################

php_binary () {
    # Don't bail out when
    # one of these comands fails
    set +e
    PHPCLI=$(which php-cli 2> /dev/null)
    PHPBINARY=$(which php 2> /dev/null)
    set -e

    if [ ! -z "$PHPCLI" ]; then
      PHPBINARY="$PHPCLI"
    fi
}

python_binary () {
    # Don't bail out when
    # one of these comands fails
    set +e
    PYTHONBIN=$(which python 2> /dev/null)
    set -e

    if [ -z "$PYTHONBIN" ]; then
      PYTHONBIN="python3"
    fi
}

php_version () {
    # 5.4, 5.5, 5.6, 7.0, 7.1
    PHPVERSION=$($PHPBINARY -v | sed -n 1p | awk '{print $2}' | cut -c1-3)
}

apache_ctl () {
    set +e
    APACHECTL=$(which apachectl 2> /dev/null)
    set -e
}

hs_version () {
    HSVERSION=$(curl -s https://store.helpspot.com/latest-release)
}


machine_type () {
    MACHINE_TYPE=`uname -m`
}

pkg_manager () {
    set +e
    YUM=$(which yum 2> /dev/null)
    APT=$(which apt-get 2> /dev/null)
    set -e

    if [ -z "$YUM" ]; then
      # APT PRESENT
      INSTALLER="$APT"
      echo "Installing lsb_release command"
      $INSTALLER install -y curl lsb-core &> /dev/null
    else
      # YUM PRESENT
      INSTALLER="$YUM"
      echo "Installing lsb_release command"
      $INSTALLER install -y curl redhat-lsb-core &> /dev/null
    fi
}

php_location () {
    # Get a php-ini location file
    ##INIFILE=$($PHPBINARY --ini | tail -n 2 | sed -n 1p)
    # /etc/php.d on redhat/centos
    # /etc/php/7.0/[cli|fpm|apache2] on debian/ubuntu <-- helpspot doesn't work on php 7 yet
    # /etc/php5/[cli|fpm|apache2] on debian/ubuntu
    ##PHPDIR=$(dirname "${INIFILE}")

    if [ -d "/etc/php.d" ]; then
        # centos/redhat
        PHPDIR="/etc/php.d"
    elif [ -d "/etc/php5/mods-available" ]; then
        # debian/ubuntu php5
        PHPDIR="/etc/php5/mods-available"
    elif [ -d "/etc/php/$PHPVERSION/mods-available" ]; then
        # debian/ubuntu newer php5.6, php7+
        PHPDIR="/etc/php/$PHPVERSION/mods-available"
    else
        echo "WARNING: Cannot find PHP directory"
        printf "\nIn what directory are php INI files located? >"
        read PHPDIR
    fi
}





######################################################################
#
# Options
#
######################################################################

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LICENSEPATH="$SCRIPTDIR/license.txt"

# getopt is NOT macintosh-friendly
OPTS=`getopt -o l: -l license: -- "$@"`
eval set -- "$OPTS"
while true ; do
    case "$1" in
        -l|--license)
            LICENSEPATH=$2
            shift 2
            ;;
        --) shift; break;;
    esac
done



######################################################################
#
# Announce ourselves, with aplomb
#
######################################################################
# TODO: To stderr?
echo " _   _      _      ____              _   "
echo "| | | | ___| |_ __/ ___| _ __   ___ | |_ "
echo "| |_| |/ _ \ | '_ \___ \| '_ \ / _ \| __|"
echo "|  _  |  __/ | |_) |__) | |_) | (_) | |_ "
echo "|_| |_|\___|_| .__/____/| .__/ \___/ \__|"
echo "             |_|        |_|              "





######################################################################
#
# Prepare Install
#
######################################################################
echo "Preparing Installation..."

php_binary
python_binary
php_version
hs_version
machine_type
pkg_manager
php_location
apache_ctl




######################################################################
#
# Auth user to retrieve license?
#
######################################################################
### - backoffice username (email)
### - password





######################################################################
#
# Download IonCube Loader
#
######################################################################

echo "Checking for IonCube Loader..."

IONCUBE_INSTALLED=$(php -r "if( extension_loaded('IonCube Loader') ) { echo 'yes'; } else { echo 'no'; };")

if [ $IONCUBE_INSTALLED = "no" ]; then
    echo "Installing IonCube Loader..."


    ###
    ### DOWNLOAD IONCUBE
    ###
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
        # 64-bit
        curl -s -o ./ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
    else
        # 32-bit
        curl -s -o ./ioncube.tar.gz  http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
    fi

    ###
    ### EXTRACT IONCUBE .SO FILES
    ###
    tar -xf ./ioncube.tar.gz

    if [ ! -f "./ioncube/ioncube_loader_lin_$PHPVERSION.so" ]; then
        >&2 echo "WARNING: Cannot match PHP version to correct IonCube Loader"
        exit 1
    fi

    ###
    ### COPY TO PHP INI DIR & CREATE .INI FILE
    ###
    cp ./ioncube/ioncube_loader_lin_$PHPVERSION.so $PHPDIR/ioncube_loader_lin_$PHPVERSION.so
    echo "zend_extension=$PHPDIR/ioncube_loader_lin_$PHPVERSION.so" > $PHPDIR/00-ioncube.ini

    # Cleanup ioncube files
    rm ./ioncube.tar.gz
    rm -r ./ioncube

    ###
    ### SYMLINK .INI FILE AS REQUIRED ON DEBIAN/UBUNTU
    ###

    # CLI probably always exists
    if [ -d "/etc/php5/cli/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php5/cli/conf.d/00-ioncube.ini
    fi

    # CLI php7 probably always exists
    if [ -d "/etc/php/$PHPVERSION/cli/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php/$PHPVERSION/cli/conf.d/00-ioncube.ini
    fi

    # If php-fpm is used
    if [ -d "/etc/php5/fpm/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php5/fpm/conf.d/00-ioncube.ini
        # Restart php-fpm
        service php5-fpm restart &> /dev/null
    fi

    # If php-fpm php7 is used
    if [ -d "/etc/php/$PHPVERSION/fpm/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php/$PHPVERSION/fpm/conf.d/00-ioncube.ini
        # Restart php-fpm
        # TODO: will eventually be php7.1-fpm
        service php7.0-fpm restart &> /dev/null
    fi

    # If apache mod-php is used
    if [ -d "/etc/php5/apache2/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php5/apache2/conf.d/00-ioncube.ini
        # Restart apache2
        service apache2 restart &> /dev/null
    fi

    # If apache mod-php php7 is used
    if [ -d "/etc/php/$PHPVERSION/apache2/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php/$PHPVERSION/apache2/conf.d/00-ioncube.ini
        # Restart apache2
        service apache2 restart &> /dev/null
    fi

    ###
    ### RESTART SERVICES on CENTOS/REDHAT
    ###

    # Restart Apache, if installed
    if [ ! -z "$APACHECTL" ]; then
        $APACHECTL restart &> /dev/null
    fi

    # Restart PHP-FPM, if installed
    set +e
    PHPFPM=$(which php-fpm 2> /dev/null)
    set -e

    if [ ! -z "$PHPFPM" ]; then
        service php-fpm restart &> /dev/null
    fi
else
    echo "IonCube installed already, moving on..."
fi





######################################################################
#
# Download HelpSpot
#
######################################################################

###
### DOWNLOAD LATEST HELPSPOT
###
# Get Latest Version
echo "Downloading Latest HelpSpot..."

# Download tar (tar is more compatible)
curl -s -o ./helpspot.tar.gz https://s3.amazonaws.com/helpspot-downloads/$HSVERSION/helpspot.tar.gz

###
### DETERMINE HELPSPOT INSTALL LOCATION
###
printf "Where should HelpSpot be installed? >"
read INSTALLPATH

### Create dir if not exists, permissions (user www-data, apache)
if [ ! -d "$INSTALLPATH" ]; then
  mkdir -p $INSTALLPATH
fi

###
### EXTRACT TO INSTALL DIR & SET PERMISSIONS
###

# Extract and delete tar file
tar -xf ./helpspot.tar.gz -C $INSTALLPATH
rm ./helpspot.tar.gz

# Move helpspot files out of install sub-dir to helpspot install dir
mv $INSTALLPATH/helpspot_$HSVERSION/* $INSTALLPATH/

# Delete empty sub-dir directory
rm -r $INSTALLPATH/helpspot_$HSVERSION

# Set Permissions
find $INSTALLPATH/ -type f -exec chmod 664 {} +
find $INSTALLPATH/ -type d -exec chmod 755 {} +
chmod +x $INSTALLPATH/hs



######################################################################
#
# Configure HelpSpot (config.php)
#
######################################################################

###
### TEMPLATE STRING FOR config.php
###
! read -d '' CONFIGTEMPLATE << EOF
<?php
/**
 * Database Credentials
 */
define('cDBTYPE',      'mysql');
define('cDBHOSTNAME',  '{{DB_HOST}}');
define('cDBUSERNAME',  '{{DB_USER}}');
define('cDBPASSWORD',  '{{DB_PASS}}');
define('cDBNAME',      '{{DB_NAME}}');

define('cDBCHARSET',   'utf8mb4');
define('cDBCOLLATION', 'utf8mb4_unicode_ci');

/**
 * Search Engine Preferences
 */
define('SEARCH_ENGINE', 'database');
define('cSEARCHHOST', '127.0.0.1');
define('cSEARCHPORT', '9306');

/**
 * General
 */
define('cHOST','{{DB_URL}}');

define('cBASEPATH',   dirname(__FILE__));
define('cDATADIR',    cBASEPATH.'/data');
define('cDEBUG',      false);
?>
EOF

###
### PROMPT FOR TEMPLATE VARIABLES
###
echo "We need some information to configure HelpSpot:"

printf "\nDatabase Host (e.g. localhost) >"
read DB_HOST

printf "\nDatabase User >"
read DB_USER

printf "\nDatabase Password >"
read DB_PASS

printf "\nDatabase Name >"
read DB_NAME

printf "\nHelpSpot URL (e.g. http://example.com/helpspot - no trailing slash)"
printf "\nUse the full URL you will use in a browser >"
read DB_URL

# Find and Replace template variables
# Strange quoting used so can use "$"character in password
CONFIG=$(sed -e 's@{{DB_HOST}}@'$DB_HOST'@' \
             -e 's@{{DB_USER}}@'$DB_USER'@' \
             -e 's@{{DB_PASS}}@'"$DB_PASS"'@' \
             -e 's@{{DB_NAME}}@'$DB_NAME'@' \
             -e 's@{{DB_URL}}@'$DB_URL'@' \
         <<< "$CONFIGTEMPLATE")

# Create config.php
# Double quotes needed to preserve line breaks
echo "$CONFIG" > $INSTALLPATH/config.php

# Set Ownership
if [ -z "$YUM" ]; then
    # APT PRESENT
    chown -R www-data:www-data $INSTALLPATH
else
    # YUM PRESENT
    chown -R apache:apache $INSTALLPATH
fi




######################################################################
#
# Install HelpSpot
#
######################################################################

###
### INSTALL HELPSPOT
###
cd $INSTALLPATH
php hs install --license-file="$LICENSEPATH"


###
### CONFIGURE SELINUX
###

# Adjust SELinux if enforcing
# May also be Permissive, but we only care about "Enforcing"
ENFORCING="Disabled"

set +e
HASSELINUX=$(which getenforce 2> /dev/null)
set -e

if [ ! -z "$HASSELINUX" ]; then
    ENFORCING=$(getenforce)
fi

if [ $ENFORCING = "Enforcing" ]; then
    # Set helpspot web file permissions
    sudo chcon -Rv --user=system_u --role=object_r --type=httpd_sys_content_t $INSTALLPATH &> /dev/null
    # Allow data directory to be written to
    sudo chcon -Rv --type=httpd_sys_content_rw_t $INSTALLPATH/data &> /dev/null
    # Enable httpd to connect to network
    setsebool -P httpd_can_network_connect on
    # Set ioncube file to correct settings for apace
    sudo chcon --user=system_u --role=object_r --type=lib_t "$PHPDIR/ioncube_loader_lin_$PHPVERSION.so"

    if [ ! -z "$APACHECTL" ]; then
        $APACHECTL restart &> /dev/null
    fi
fi


###
### Setup Cron Tasks
###

echo "Setting HelpSpot CRON Tasks"

HELPSPOTCRONFILE=/etc/cron.d/helpspot

if [ -z "$YUM" ]; then
    # APT PRESENT
    HSCRONUSER='www-data'
else
    # YUM PRESENT
    HSCRONUSER='apache'
fi

sh -c "echo '*/2 * * * * $HSCRONUSER $PHPBINARY $INSTALLPATH/tasks.php' > $HELPSPOTCRONFILE"
sh -c "echo '* * * * * $HSCRONUSER $PHPBINARY $INSTALLPATH/tasks2.php' >> $HELPSPOTCRONFILE"


echo "Installation Complete!"
echo "You can reach your HelpSpot installation at $DB_URL"
