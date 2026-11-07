@wile_order
Feature: Testing wile order task

  Background:
    * Given command "./bin/wile"

  Scenario: order on ordered file
    * Given option "order test/tc_comments"
    * When we run command
    * Then exit status is "0"
    * Then stderr includes "# Start:"
    * Then stderr includes "# End:"
    * Then stdout includes "TestComments#test_comments"

  Scenario: order sample with default sort (bcmv)
    * Given option "order features/fixtures/sample.rb"
    * When we run command
    * Then stdout is fixture 'sample.bcmv'
    * Then exit status is "1"
    * Then stderr includes "Sort: bcmv"

  Scenario: order sample with bprm
    * Given option "order features/fixtures/sample.rb bprm"
    * When we run command
    * Then stdout is fixture 'sample.bprm'
    * Then exit status is "1"
    * Then stderr includes "Sort: bprm"

  Scenario: order sample with bcmv
    * Given option "order features/fixtures/sample.rb bcmv"
    * When we run command
    * Then stdout is fixture 'sample.bcmv'
    * Then exit status is "1"
    * Then stderr includes "Sort: bcmv"

  Scenario: order sample with cswp
    * Given option "order features/fixtures/sample.rb cswp"
    * When we run command
    * Then stdout is fixture 'sample.cswp'
    * Then exit status is "1"
    * Then stderr includes "Sort: cswp"

  Scenario: order sample with bnswp
    * Given option "order features/fixtures/sample.rb bnswp"
    * When we run command
    * Then stdout is fixture 'sample.bnswp'
    * Then exit status is "1"
    * Then stderr includes "Sort: bnswp"

  Scenario: order sample with bcswp
    * Given option "order features/fixtures/sample.rb bcswp"
    * When we run command
    * Then stdout is fixture 'sample.bcswp'
    * Then exit status is "1"
    * Then stderr includes "Sort: bcswp"

  Scenario: order sample with nswp
    * Given option "order features/fixtures/sample.rb nswp"
    * When we run command
    * Then stdout is fixture 'sample.nswp'
    * Then exit status is "1"
    * Then stderr includes "Sort: nswp"

  Scenario: order with qc special subcommand
    * Given option "order features/fixtures/sample.rb qc"
    * When we run command
    * Then exit status is "0"
    * Then stdout is "OK"

  Scenario: order with non-existent file
    * Given option "order nonexistent_file.rb"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "does not exist: nonexistent_file.rb"

  Scenario: order with invalid sort type
    * Given option "order features/fixtures/sample.rb invalid_sort"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "invalid sort: invalid_sort"

  Scenario: order with too many arguments
    * Given option "order features/fixtures/sample.rb bnswp extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or two arguments."

  Scenario: order with disallowed option
    * Given option "order features/fixtures/sample.rb --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or two arguments."
