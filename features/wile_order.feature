@wile_order
Feature: Testing wile order

  Background:
    * Given command "./bin/wile"

  Scenario: order on ordered file
    * Given option "order test/tc_comments"
    * When we run command
    * Then exit status is "0"
    * Then stderr includes "# Start:"
    * Then stderr includes "# End:"
    * Then stdout includes "TestComments#test_comments"
