<?php

require_once('../vendor/autoload.php');

use \Michelf\MarkdownExtra;
$parser = new MarkdownExtra;

$html = $parser->transform(file_get_contents('../README.md'));?><!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, minimal-ui">
        <title>HelpSpot Installer</title>
        <link rel="stylesheet" href="/markdown.css">
        <style>
            .markdown-body {
                box-sizing: border-box;
                min-width: 200px;
                max-width: 980px;
                margin: 0 auto;
                padding: 45px;
            }
        </style>
    </head>
    <body>
        <article class="markdown-body">
        <?php echo $html; ?>
        </article>
    </body>
</html>