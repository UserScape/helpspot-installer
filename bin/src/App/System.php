<?php

namespace App;


class System
{
    protected $cli;

    public $php_cli;
    public $php_fpm;
    public $php_version;
    public $php_config;
    public $apachectl;
    public $architecture;
    public $deb;
    public $rpm;
    public $pkgmgr;

    public function __construct(CommandLine $cli)
    {
        $this->cli = $cli;

        $this->php();
        $this->apache();
        $this->server();
    }

    public function install($package, $fn=null)
    {
        if(is_array($package))
        {
            $package = implode(' ', $package);
        }

        $this->cli->run("sudo $this->pkgmgr install -y $package", $fn);
    }

    public function is64()
    {
        return ($this->architecture == 'x86_64');
    }

    protected function php()
    {
        // Binary location
        $this->php_cli = $this->cli->find("php-cli");

        if( ! $this->php_cli )
        {
            $this->php_cli = $this->cli->findOrFail("php");
        }

        // PHP Version (5.6, 5.5, 5.4)
        $this->php_version = $this->cli->run("$this->php_cli -v | sed -n 1p | awk '{print $2}' | cut -c1-3");

        // PHP-FPM
        $this->php_fpm = $this->cli->find("php-fpm");

        if( ! $this->php_fpm )
        {
            $this->php_fpm = $this->cli->find("php5_fpm");
        }

        // PHP Config Directory
        if( file_exists('/etc/php.d') )
        {
            $this->php_config = '/etc/php.d';
        } elseif( file_exists('/etc/php5/mods-available') )
        {
            $this->php_config = '/etc/php5/mods-available';
        } else {
            // Else ask this where ... but not here.
            // SRP, you understand.
        }
    }

    protected function apache()
    {
        $this->apachectl = $this->cli->find('apachectl');
    }

    protected function server()
    {
        $this->architecture = $this->cli->run('uname -m');

        $this->deb = $this->cli->find('apt-get');
        $this->rpm = $this->cli->find('yum');
        $this->pkgmgr = ($this->deb) ? $this->deb : $this->rpm;
    }
}