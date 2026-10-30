@wile_content
Feature: Testing wile content

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
