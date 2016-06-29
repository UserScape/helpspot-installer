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
php_version
hs_version
machine_type
pkg_manager
php_location





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

if [ "$IONCUBE_INSTALLED" -eq "no" ]; then
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

    ###
    ### SYMLINK .INI FILE AS REQUIRED ON DEBIAN/UBUNTU
    ###
    # CLI probably always exists
    if [ -d "/etc/php5/cli/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php5/cli/conf.d/00-ioncube.ini
    fi
    # If php-fpm is used
    if [ -d "/etc/php5/fpm/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php5/fpm/conf.d/00-ioncube.ini
    fi
    # If apache mod-php is used
    if [ -d "/etc/php5/apache2/conf.d" ]; then
        # debian/ubuntu
        ln -s $PHPDIR/00-ioncube.ini /etc/php5/fpm/conf.d/00-ioncube.ini
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
echo "Where should HelpSpot be installed?"
read INSTALLPATH

### Create dir if not exists, permissions (user www-data, httpd)
if [ ! -d "$INSTALLPATH" ]; then
  mkdir -p $INSTALLPATH
fi

###
### EXTRACT TO INSTALL DIR & SET PERMISSIONS
###
# Extract
tar -xf ./helpspot.tar.gz -C $INSTALLPATH
# Move helpspot files out of install sub-dir to helpspot install dir
mv $INSTALLPATH/helpspot_$HSVERSION/* $INSTALLPATH/
# Delete empty sub-dir directory
rm -r $INSTALLPATH/helpspot_$HSVERSION
# Set Permissions
find $INSTALLPATH/ -type f -exec chmod 664 {} +
find $INSTALLPATH/ -type d -exec chmod 755 {} +
chmod guo+x $INSTALLPATH/hs





######################################################################
#
# Configure HelpSpot (config.php)
#
######################################################################





######################################################################
#
# Install HelpSpot
#
######################################################################

## php hs install
### Allow this to [prompt]




######################################################################
#
# Download & Configure SphinxSearch
#
######################################################################

## SphinxSearch
### Download (latest?) version
### Adjust init if required
### php hs search:config
### Move to /etc/sphinx[search]/sphinx.conf
### Setup cron tasks for indexing
### Run indexer (hide output)





######################################################################
#
# UTILITY FUNCTIONS
#
######################################################################

php_binary () {
    PHPCLI=$(which php-cli 2> /dev/null)
    PHPBINARY=$(which php 2> /dev/null)

    if [ ! -z "$PHPCLI" ]; then
      PHPBINARY="$PHPCLI"
    fi
}

php_version () {
    # 5.4, 5.5, 5.6
    PHPVERSION=$($PHPBINARY -v | sed -n 1p | awk '{print $2}' | cut -c1-3)
}

hs_version () {
    HSVERSION=$(curl -s https://store.helpspot.com/latest-release)
}


machine_type () {
    MACHINE_TYPE=`uname -m`
}

pkg_manager () {
    YUM=$(which yum)
    APT=$(which apt-get)

    if [ -z "$YUM" ]; then
      # APT PRESENT
      INSTALLER="$APT"
    else
      # YUM PRESENT
      INSTALLER="$YUM"
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
        # debian/ubuntu
        PHPDIR="/etc/php5/mods-available"
    else
        echo "WARNING: Cannot find PHP directory"
        echo "In what directory are php INI files located?"
        read PHPDIR
    fi
}

