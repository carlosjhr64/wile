@wile_lexicon
Feature: Testing wile lexicon task

  Background:
    * Given command "./bin/wile"

  Scenario: lexicon --check
    * Given option "lexicon --check"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is 'OK'

  Scenario: lexicon with disallowed argument
    * Given option "lexicon extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."

  Scenario: lexicon with disallowed option
    * Given option "lexicon --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments."
