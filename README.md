# helpspot-installer
Customer Installer for HelpSpot

## TO DO:

Baseline:

* Cleanup function
    - excess files
    - cleanup on error
* Create config.php (prompt for database info)
* `php hs install`
* Will license be included? (prompt for path if not exists)
* install/configure sphinxsearch

Security:

Set location to get md5 hash of shell script to verify location if install directions end up being `curl [our cript url] | sudo bash`.

## OS Parsing

```
# See also: http://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script


# centos / redhat
cat /etc/redhat-release
> CentOS release 6.7 (Final)
> Red Hat Enterprise Linux Server release 7.2 (Maipo)
> Red Hat Enterprise Linux Server release 6.5 (Santiago)

# amzn linux
cat /etc/system-release
> Amazon Linux AMI release 2016.03

# debian/ubuntu
cat /etc/lsb-release [-r for release]
> Distributor ID: Ubuntu
> Description:    Ubuntu 14.04.2 LTS
> Release:    14.04
> Codename:   trusty
```