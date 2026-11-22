@wile_build
Feature: Testing wile build task

  Background:
    * Given command "./bin/wile"

  Scenario: build with disallowed argument
    * Given option "build extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional force flag."

  Scenario: build with disallowed option
    * Given option "build --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional force flag."

  Scenario: build with extra argument and force option
    * Given option "build extra --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional force flag."
