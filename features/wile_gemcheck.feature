@wile_gemcheck
Feature: Testing wile gemcheck task

  Background:
    * Given command "./bin/wile"

  Scenario: gemcheck with disallowed argument
    * Given option "gemcheck extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional all flag."

  Scenario: gemcheck with disallowed option
    * Given option "gemcheck --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional all flag."

  Scenario: gemcheck with extra argument and all option
    * Given option "gemcheck extra --all"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional all flag."
