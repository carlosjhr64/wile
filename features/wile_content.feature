@wile_content
Feature: Testing wile content task

  Background:
    * Given command "./bin/wile"

  Scenario: content with no arguments
    * Given option "content"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or more filenames."

  Scenario: content with disallowed option
    * Given option "content features/fixtures/sample.rb --check"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or more filenames."

  Scenario: content with conflicting dump and raw options
    * Given option "content features/fixtures/sample.rb --dump --raw"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Cannot combine --dump and --raw."

  Scenario: content with invalid filename characters
    * Given option "content bad@file.rb"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or more filenames."

  Scenario: content on non-existent file
    * Given option "content nonexistent_file_xyz.rb"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "File not found: nonexistent_file_xyz.rb"
    * Then stderr includes "No files selected."

  Scenario: content on directory
    * Given option "content lib/"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "File not found: lib/"
    * Then stderr includes "No files selected."

  Scenario: content with valid and missing files
    * Given option "content features/fixtures/sample.rb nonexistent_xyz.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr includes "File not found: nonexistent_xyz.rb"
    * Then stdout includes "features/fixtures/sample.rb"
