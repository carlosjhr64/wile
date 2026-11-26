@wile_oscheck
Feature: Testing wile oscheck task

  Background:
    * Given command "./bin/wile"

  Scenario: oscheck default
    * Given option "oscheck"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "ruby:"
    * Then stdout includes "git:"
    * Then stdout includes "bash:"

  Scenario: oscheck with all option
    * Given option "oscheck --all"
    * When we run command
    * Then exit status is "2"
    * Then stderr includes "commands not found"
    * Then stdout includes "ruby:"
    * Then stdout includes "git:"
    * Then stdout includes "-"

  Scenario: oscheck with disallowed argument
    * Given option "oscheck extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional all flag."

  Scenario: oscheck with disallowed option
    * Given option "oscheck --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional all flag."
