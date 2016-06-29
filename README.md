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
