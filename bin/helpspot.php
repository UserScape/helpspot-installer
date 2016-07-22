#!/usr/bin/env php
<?php

require_once(__DIR__.'/vendor/autoload.php');

use Silly\Application;

$version = '1.0.0';
$app = new Application('HelpSpot Install', $version);

$app->command('install [--license]', ['App\Commands\Install', 'run']);

$app->command('test', function() {
    output(info('This has been a successful unveiling'));
});

$app->run();
