@version
Feature: Testing wile version

  Background:
    * Given command "./bin/wile"

  Scenario: --version
    * Given option "--version"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /\A\d+\.\d+\.\d+\z/

  Scenario: -v
    * Given option "-v"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout matches /\A\d+\.\d+\.\d+\z/
