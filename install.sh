#!/usr/bin/env bash

# Bail on first error
set -e

# Most things here will need a centos/redhat vs debian/ubuntu 
#  install paths

# We'll assume php and web server (apache or nginx) already setup

## Auth user to retrieve license
### - backoffice username (email)
### - password

## Download IonCube Loader
### Optionally skip this step ([prompt]?)
### Unzip to php lib dir (need root)
### Setup php.ini settings (requires root)

## Download latest helpspot
### Get Latest Version
### Download tar (tar is more compatible)
### [Prompt] location helpspot should live in
### Create dir if not exists, permissions (user www-data, httpd)

## config.php - prompt for database details?
### Template to fill out config.php

## php hs install
### Allow this to [prompt]

## SphinxSearch
### Download (latest?) version
### Adjust init if required
### php hs search:config
### Move to /etc/sphinx[search]/sphinx.conf
### Setup cron tasks for indexing
### Run indexer (hide output)


