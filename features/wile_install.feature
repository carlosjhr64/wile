@wile_install
Feature: Testing wile install task

  Background:
    * Given command "./bin/wile"

  Scenario: install with disallowed argument
    * Given option "install extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional force flag."

  Scenario: install with disallowed option
    * Given option "install --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional force flag."

  Scenario: install with extra argument and force option
    * Given option "install extra --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional force flag."
