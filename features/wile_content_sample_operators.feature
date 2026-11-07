@wile_content
Feature: Testing wile content task with sample_operators fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample.rb
    * Given option "content ./features/fixtures/sample_operators.rb"
    * When we run command
    * Then stdout is fixture 'sample_operators.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --raw
    * Given option "content ./features/fixtures/sample_operators.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_operators.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --dump
    * Given option "content ./features/fixtures/sample_operators.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_operators.dump'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_operators.rb"
