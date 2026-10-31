@wile_list
Feature: Testing wile list

  Background:
    * Given command "./bin/wile"

  Scenario: list
    * Given option "list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^# Show task's help:$/
    * Then stdout matches /^\s*wile\s+help\s+\[<task>\+\]$/
    * Then stdout matches /^# Runs tests:$/
    * Then stdout matches /^\s*wile\s+test\s+\[<match>\+\]$/

  Scenario: list --list
    * Given option "list --list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^\+ help: show task's help$/
    * Then stdout matches /^\+ test: runs tests$/

  Scenario: list test
    * Given option "list test"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout does not match /^\s*wile\s+help\s+\[<task>\+\]$/
    * Then stdout matches /^\s*wile\s+test\s+\[<match>\+\]$/
