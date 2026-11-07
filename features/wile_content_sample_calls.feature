@wile_content
Feature: Testing wile content task with sample_calls fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_calls.rb
    * Given option "content ./features/fixtures/sample_calls.rb"
    * When we run command
    * Then stdout is fixture 'sample_calls.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_calls.rb --raw
    * Given option "content ./features/fixtures/sample_calls.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_calls.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_calls.rb --dump
    * Given option "content ./features/fixtures/sample_calls.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_calls.dump'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_calls.rb"
