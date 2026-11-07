@wile_content
Feature: Testing wile content task with sample_constants fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_constants.rb
    * Given option "content ./features/fixtures/sample_constants.rb"
    * When we run command
    * Then stdout is fixture 'sample_constants.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_constants.rb --raw
    * Given option "content ./features/fixtures/sample_constants.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_constants.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_constants.rb --dump
    * Given option "content ./features/fixtures/sample_constants.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_constants.dump'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_constants.rb"
