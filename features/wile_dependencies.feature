@wile_dependencies
Feature: Testing wile dependencies task

  Background:
    * Given command "./bin/wile"

  Scenario: dependencies sections
    * Given option "dependencies"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "## runtime ##"
    * Then stdout includes "## development ##"
    * Then stdout includes "## system-run ##"
    * Then stdout includes "## system-dev ##"

  @local
  Scenario: dependencies matches dependencies.txt
    * Given option "dependencies"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'dependencies.txt'

  Scenario: dependencies with disallowed argument
    * Given option "dependencies extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."

  Scenario: dependencies with disallowed option
    * Given option "dependencies --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."
