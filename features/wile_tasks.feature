@wile_tasks
Feature: Testing wile tasks

  Background:
    * Given command "./bin/wile"

  Scenario: content
    * Given option "content test/local/sample.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "test/local/sample.rb"

  Scenario: content with raw option
    * Given option "content test/local/sample.rb -r"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "casgn A::B::C lambda"
    * Then stdout includes "def A::B#initialize"

  Scenario: list
    * Given option "list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "content"
    * Then stdout includes "order"

  Scenario: help
    * Given option "help"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "wile help"
    * Then stdout includes "wile list"

  Scenario: order on ordered file
    * Given option "order test/tc_comments"
    * When we run command
    * Then exit status is "0"
    * Then stderr includes "# Start:"
    * Then stderr includes "# End:"
    * Then stdout includes "TestComments#test_comments"
