@wile_content
Feature: Testing wile content task with sample_attrs fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_attrs.rb
    * Given option "content ./features/fixtures/sample_attrs.rb"
    * When we run command
    * Then stdout is fixture 'sample_attrs.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_attrs.rb --raw
    * Given option "content ./features/fixtures/sample_attrs.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_attrs.raw'
    * Then exit status is "0"
    * Then stderr is ""
