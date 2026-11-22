@wile_review
Feature: Testing wile review task

  Background:
    * Given command "./bin/wile"

  Scenario: review with too many arguments
    * Given option "review one two"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "May take one target with optional all/strict/only"

  Scenario: review with disallowed option
    * Given option "review --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "May take one target with optional all/strict/only"

  Scenario: review with non-matching target
    * Given option "review nonexistent_xyz_123"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "no match for nonexistent_xyz_123"

  Scenario: review with unknown check name
    * Given option "review lib/wile/sysexits.rb --only=bogus"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "Unknown checks: bogus"
