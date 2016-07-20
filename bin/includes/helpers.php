<?php

/**
 * Output the given text to the console.
 *
 * @param  string  $output
 * @return void
 */
function info($output)
{
    output('<info>'.$output.'</info>');
}

/**
 * Output the given text to the console.
 *
 * @param  string  $output
 * @return void
 */
function warning($output)
{
    output('<fg=red>'.$output.'</>');
}

/**
 * Output the given text to the console.
 *
 * @param  string $output
 * @param bool $stderr
 */
function output($output, $stderr=true)
{

    $console = new Symfony\Component\Console\Output\ConsoleOutput;

    if( $stderr )
    {
        return $console->getErrorOutput()->writeln($output);
    }

    return $console->writeln($output);
}