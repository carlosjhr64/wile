@wile_content
Feature: Testing wile content task with sample_operators fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample.rb
    * Given option "content ./features/fixtures/sample_operators.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'sample_operators.txt'

  Scenario: content sample.rb --raw
    * Given option "content ./features/fixtures/sample_operators.rb --raw"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'sample_operators.raw'

  Scenario: content sample.rb --dump
    * Given option "content ./features/fixtures/sample_operators.rb --dump"
    * When we run command
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_operators.rb"
    * Then stdout is fixture 'sample_operators.dump'
