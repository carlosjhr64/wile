@wile_content
Feature: Testing wile content task with sample_operators fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content operator methods
    * Given option "content features/fixtures/sample_operators.rb -r"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "def SampleOperators::Calculator#=="
    * Then stdout includes "def SampleOperators::Calculator#!="
    * Then stdout includes "def SampleOperators::Calculator#<=>"
    * Then stdout includes "def SampleOperators::Calculator#<"
    * Then stdout includes "def SampleOperators::Calculator#<="
    * Then stdout includes "def SampleOperators::Calculator#>"
    * Then stdout includes "def SampleOperators::Calculator#>="
    * Then stdout includes "def SampleOperators::Calculator#==="
    * Then stdout includes "def SampleOperators::Calculator#+"
    * Then stdout includes "def SampleOperators::Calculator#-"
    * Then stdout includes "def SampleOperators::Calculator#*"
    * Then stdout includes "def SampleOperators::Calculator#/"
    * Then stdout includes "def SampleOperators::Calculator#%"
    * Then stdout includes "def SampleOperators::Calculator#**"
    * Then stdout includes "def SampleOperators::Calculator#<<"
    * Then stdout includes "def SampleOperators::Calculator#>>"
    * Then stdout includes "def SampleOperators::Calculator#&"
    * Then stdout includes "def SampleOperators::Calculator#|"
    * Then stdout includes "def SampleOperators::Calculator#^"
    * Then stdout includes "def SampleOperators::Calculator#~"
    * Then stdout includes "def SampleOperators::Calculator#+@"
    * Then stdout includes "def SampleOperators::Calculator#-@"
    * Then stdout includes "def SampleOperators::Calculator#!@"
    * Then stdout includes "def SampleOperators::Calculator#[]"
    * Then stdout includes "def SampleOperators::Calculator#[]="
    * Then stdout includes "def SampleOperators::Calculator.=="
    * Then stdout includes "def SampleOperators::Calculator.<<"
