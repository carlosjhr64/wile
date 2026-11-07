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
    * Then stdout is fixture 'sample.dump'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample.rb"

  Scenario: content on non-existent file
    * Given option "content nonexistent_file_xyz.rb"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "File not found: nonexistent_file_xyz.rb"
    * Then stderr includes "No files selected."

  Scenario: content with disallowed option
    * Given option "content features/fixtures/sample.rb --check"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or more filenames."
