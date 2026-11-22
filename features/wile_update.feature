@wile_update
Feature: Testing wile update task

  Background:
    * Given command "./bin/wile"

  Scenario: update with invalid target
    * Given option "update invalid"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "May specify README, gemspec, or man."

  Scenario: update with too many arguments
    * Given option "update README man"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "May specify README, gemspec, or man."

  Scenario: update with disallowed option
    * Given option "update --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "May specify README, gemspec, or man."

  Scenario: update with invalid target and force option
    * Given option "update invalid --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "May specify README, gemspec, or man."
