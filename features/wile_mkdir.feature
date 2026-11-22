@wile_mkdir
Feature: Testing wile mkdir task

  Background:
    * Given command "./bin/wile"

  Scenario: mkdir with no arguments
    * Given option "mkdir"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: mkdir with too many arguments
    * Given option "mkdir one two"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: mkdir with invalid directory name
    * Given option "mkdir bad@name"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: mkdir with disallowed option
    * Given option "mkdir lib --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: mkdir on existing directory
    * Given option "mkdir lib"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "lib exists!"
