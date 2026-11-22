@wile_content
Feature: Testing wile content task with sample fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample.rb
    * Given option "content ./features/fixtures/sample.rb"
    * When we run command
    * Then stdout is fixture 'sample.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --raw
    * Given option "content ./features/fixtures/sample.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --dump
    * Given option "content ./features/fixtures/sample.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample.sexp'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample.rb"
