<?php

namespace App;

use Symfony\Component\Process\Process;

class CommandLine
{
    /**
     * Simple global function to run commands.
     *
     * @param  string  $command
     * @return void
     */
    public function quietly($command)
    {
        $this->runCommand($command.' > /dev/null 2>&1');
    }
    /**
     * Simple global function to run commands.
     *
     * @param  string  $command
     * @return void
     */
    public function quietlyAsUser($command)
    {
        $this->quietly('sudo -u '.user().' '.$command.' > /dev/null 2>&1');
    }
    /**
     * Pass the command to the command line and display the output.
     *
     * @param  string  $command
     * @return void
     */
    public function passthru($command)
    {
        passthru($command);
    }
    /**
     * Run the given command as the non-root user.
     *
     * @param  string  $command
     * @param  callable $onError
     * @return string
     */
    public function run($command, callable $onError = null)
    {
        return $this->runCommand($command, $onError);
    }
    /**
     * Run the given command.
     *
     * @param  string  $command
     * @param  callable $onError
     * @return string
     */
    public function runAsUser($command, callable $onError = null)
    {
        return $this->runCommand('sudo -u '.user().' '.$command, $onError);
    }

    /**
     * Get the location of a binary or throw an exception
     * @param $binary
     * @return string
     * @throws \Exception
     */
    public function findOrFail($binary)
    {
        $location = $this->find($binary);

        if ( ! $location )
        {
            throw new \Exception("Binary '$binary' cannot be found.");
        }

        return $location;
    }
    /**
     * Get the location of a binary
     * @param $binary
     * @return null|string
     */
    public function find($binary)
    {
        $exists = true;

        $location = $this->runCommand("which ".$binary, function() use (&$exists) {
            $exists = false;
        });

        return ( ! $exists ) ? false : trim($location);
    }

    /**
     * Run the given command.
     *
     * @param  string  $command
     * @param  callable $onError
     * @return string
     */
    protected function runCommand($command, callable $onError = null)
    {
        $onError = $onError ?: function () {};
        $process = new Process($command);
        $processOutput = '';
        $process->setTimeout(null)->run(function ($type, $line) use (&$processOutput) {
            $processOutput .= $line;
        });
        if ($process->getExitCode() > 0) {
            $onError($process->getExitCode(), $processOutput);
        }
        return trim($processOutput);
    }
}