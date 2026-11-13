@wile_list
Feature: Testing wile list task

  Background:
    * Given command "./bin/wile"

  Scenario: list
    * Given option "list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^# .+:$/
    * Then stdout matches /^\s*wile\s+help\b/
    * Then stdout matches /^\s*wile\s+test\b/

  Scenario: list with dictionary format
    * Given option "list --format=dictionary"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^\+ help: .+/
    * Then stdout matches /^\+ test: .+/

  Scenario: list with name format
    * Given option "list test --format=name"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^\s*test\s*$/

  Scenario: list with code format
    * Given option "list test --format=code"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^wile\s+test\s+/

  Scenario: list with invalid format
    * Given option "list --format=invalid"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Unrecognized format 'invalid'"

  Scenario: list with disallowed option
    * Given option "list --list"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "with optional format flag"

  Scenario: list test
    * Given option "list test"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout does not match /^\s*wile\s+help\b/
    * Then stdout matches /^\s*wile\s+test\b/
