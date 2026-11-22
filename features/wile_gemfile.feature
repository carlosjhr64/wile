@wile_gemfile
Feature: Testing wile gemfile task

  Background:
    * Given command "./bin/wile"

  Scenario: gemfile with disallowed argument
    * Given option "gemfile extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."

  Scenario: gemfile with disallowed option
    * Given option "gemfile --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."
