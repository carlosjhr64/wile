@wile_dictionary
Feature: Testing wile dictionary task

  Background:
    * Given command "./bin/wile"

  Scenario: dictionary --check
    * Given option "dictionary --check"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is 'OK'

  Scenario: dictionary with disallowed argument
    * Given option "dictionary extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."

  Scenario: dictionary with disallowed option
    * Given option "dictionary --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."
