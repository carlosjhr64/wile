@wile_man
Feature: Testing wile man

  Background:
    * Given command "./bin/wile"

  Scenario: man
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /^# wile/
