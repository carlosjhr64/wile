@wile_cp
Feature: Testing wile cp task

  Background:
    * Given command "./bin/wile"

  Scenario: cp existing file with --trace skips overwrite
    * Given option "cp tc_encoding --trace"
    * When we run command
    * Then exit status is "0"
    * Then stdout is ''
    * Then stderr includes "test/tc_encoding"

  Scenario: cp with non-matching pattern
    * Given option "cp nonexistent_xyz_123"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "no matches found"

  Scenario: cp with too many arguments
    * Given option "cp one two"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one argument and flags:"

  Scenario: cp with disallowed option
    * Given option "cp --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one argument and flags:"
