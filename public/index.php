<?php

require_once('../vendor/autoload.php');

$script = file_get_contents('../install.sh');
$md5checksum = md5($script);

use \Michelf\MarkdownExtra;
$parser = new MarkdownExtra;

$html = $parser->transform(file_get_contents('../README.md'));?><!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, minimal-ui">
        <title>HelpSpot Installer</title>
        <link rel="icon" type="image/png" href="https://www.helpspot.com/images/favicon.png">
        <link rel="stylesheet" href="/markdown.css">
        <!-- <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.5.0/styles/default.min.css"> -->
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
            <?php echo str_replace('{{md5checksum}}', $md5checksum, $html); ?>
        </article>

        <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.5.0/highlight.min.js"></script>
        <script>hljs.initHighlightingOnLoad();</script>
    </body>
</html>