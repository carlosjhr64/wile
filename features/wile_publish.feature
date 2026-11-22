@wile_publish
Feature: Testing wile publish task

  Background:
    * Given command "./bin/wile"

  Scenario: publish with no arguments
    * Given option "publish"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: publish with too many arguments
    * Given option "publish 1.0.0 2.0.0"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: publish with invalid version format
    * Given option "publish invalid"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: publish with disallowed option
    * Given option "publish 0.0.0 --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one argument."

  Scenario: publish with mismatched version
    * Given option "publish 0.0.0"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "0.0.0"
