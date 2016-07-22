<?php

namespace App\Commands;

use App\System;
use App\CommandLine;

class Install
{
    /**
     * @var System
     */
    private $system;

    /**
     * @var CommandLine
     */
    private $cli;

    /**
     * @param System $system
     * @param CommandLine $cli
     */
    public function __construct(System $system, CommandLine $cli)
    {
        $this->system = $system;
        $this->cli = $cli;
    }

    public function go($license)
    {
        $license = ($license) ? $license : 'license.txt';

        // 1. Install any requirements
        $this->installRequirements();

        // 2. HELPSPOT BANNER

        // 3. IonCube Loader
        $this->ioncube();

        // 4. HelpSpot Files
        $this->helpspot();
    }

    protected function installRequirements()
    {
        $requirements = ($this->system->deb) ? ['curl', 'lsb-core'] : ['curl', 'redhat-lsb-core'];
        $this->system->install($requirements, function() use($requirements)
        {
            throw new \Exception("Failed to install packages $requirements");
        });
    }

    protected function ioncube()
    {
        if( ! extension_loaded('IonCube Loader') )
        {
            // Download ioncube
            $url = ($this->system->is64())
                ? 'http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz'
                : 'http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz';
            file_put_contents('ioncube.tar.gz', file_get_contents($url));

            // Uncompress
            $this->cli->run("tar -xf ioncube.tar.gz");

            if( ! file_exists("ioncube/ioncube_loader_lin_{$this->system->php_version}.so") )
            {
                throw new \Exception("Cannot match PHP version to correct IonCube Loader");
            }

            // Configure PHP
            copy("ioncube/ioncube_loader_lin_{$this->system->php_version}.so",
                 "{$this->system->php_config}/ioncube_loader_lin_{$this->system->php_version}.so");

            file_put_contents("{$this->system->php_config}/00-ioncube.ini",
                              "zend_extension={$this->system->php_config}/ioncube_loader_lin_{$this->system->php_version}.so");

            // Cleanup
            unlink("ioncube.tar.gz");
            $this->cli->run('rm -rf ioncube');

            // Symlink in deb
            if( $this->system->deb )
            {
                foreach(['/etc/php5/cli/conf.d', '/etc/php5/fpm/conf.d', '/etc/php5/apache2/conf.d'] as $deb_dir)
                {
                    if( file_exists($deb_dir) )
                    {
                        $this->cli->run("ln -s {$this->system->php_config}/00-ioncube.ini {$deb_dir}/00-ioncube.ini");
                    }
                }
            }

            // Restart any services
            if( $this->system->apachectl )
            {
                $this->cli->run("{$this->system->apachectl} restart");
            }

            if( $this->system->php_fpm )
            {
                $this->cli->run("service {$this->system->php_fpm} restart");
            }
        }
    }

    protected function helpspot()
    {
        // Download HelpSpot
        $version = file_get_contents('https://store.helpspot.com/latest-release');
        $url = "https://s3.amazonaws.com/helpspot-downloads/{$version}/helpspot.tar.gz";
        file_put_contents('helpspot.tar.gz', file_get_contents($url));

        // TODO: Ask Install Path
        $install_path = '/var/www/helpspot';
        if( ! file_exists($install_path) ) $this->cli->run("mkdir -p {$install_path}");
    }

    public static function run($license)
    {
        $cli = new CommandLine;
        $system = new System($cli);
        return (new static($system, $cli))->go($license);
    }
}