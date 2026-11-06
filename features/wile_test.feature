@wile_test
Feature: Testing wile test task

  Background:
    * Given command "./bin/wile"

  Scenario: test --list
    * Given option "test --list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "test/tc_ut_usage"
    * Then stdout includes "test/tc_cucumber"

  Scenario: test with filematch and --list
    * Given option "test usage --list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is 'test/tc_ut_usage'

  Scenario: test with filematch and methodmatch (quiet)
    * Given option "test usage initialize -q"
    * When we run command
    * Then exit status is "0"
    * Then stdout includes "18 tests, 19 assertions"
    * Then stdout includes "OK"

  Scenario: test with non-matching filematch
    * Given option "test nonexistent_pattern"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "No tests matched: nonexistent_pattern"

  Scenario: test with too many arguments
    * Given option "test one two three"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes at most two arguments"

  Scenario: test with invalid option
    * Given option "test --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "optional list/quiet flags"
