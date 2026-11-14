@wile_info
Feature: Testing wile info task

  Background:
    * Given command "./bin/wile"

  Scenario: info
    * Given option "info"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "# wile"
    * Then stdout includes "+ Version:"
    * Then stdout includes "+ Author:"
    * Then stdout includes "## Description"
    * Then stdout includes "## Files"
    * Then stdout includes "## Executables"
    * Then stdout includes "## Runtime gems"
    * Then stdout includes "## Development gems"

  Scenario: info with disallowed argument
    * Given option "info extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."

  Scenario: info with disallowed option
    * Given option "info --all"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."
