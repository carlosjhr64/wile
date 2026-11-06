@wile_content
Feature: Testing wile content task with sample fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content
    * Given option "content ./features/fixtures/sample.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'sample.txt'

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
