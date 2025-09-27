@wile_tasks
Feature: Testing wile tasks

  Background:
    * Given command "./bin/wile"

  Scenario: content
    * Given option "content test/local/sample.rb"
    * When we run command
    * Then exit status is "0"
