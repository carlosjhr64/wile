@wile_help
Feature: Testing wile help

  Background:
    * Given command "./bin/wile"

  Scenario: help
    * Given option "help"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "wile help"
    * Then stdout includes "wile list"

  Scenario: help test
    * Given option "help test"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "wile test [<match>+]"
