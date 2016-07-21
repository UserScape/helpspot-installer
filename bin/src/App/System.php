<?php

namespace App;


class System
{
    protected $cli;

    protected $php_cli;
    protected $php_version;
    protected $php_config;
    protected $apachectl;
    protected $architecture;
    protected $deb;
    protected $rpm;
    protected $pckmgr;

    public function __construct(CommandLine $cli)
    {
        $this->cli = $cli;

        $this->php();
        $this->apache();
        $this->server();
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
        $this->pckmgr = ($this->deb) ? $this->deb : $this->rpm;
    }
}