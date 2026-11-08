# frozen_string_literal: true

# rubocop:disable Lint/UnusedMethodArgument
# :reek:IrresponsibleModule :reek:TooManyMethods
# :reek:UncommunicativeMethodName :reek:UtilityFunction
module SampleOperators
  # :reek:IrresponsibleModule :reek:TooManyMethods
  # :reek:UncommunicativeMethodName :reek:UnusedParameters
  # :reek:UtilityFunction
  class Calculator
    def ==(other) = other == self
    def !=(other) = other != self
    def <=>(other) = 0
    def <(other) = false
    def <=(other) = true
    def >(other) = false
    def >=(other) = true
    def ===(other) = true
    def =~(other) = false
    def !~(other) = true
    def +(other) = other
    def -(other) = other
    def *(other) = other
    def /(other) = other
    def %(other) = other
    def **(other) = other
    def <<(other) = other
    def >>(other) = other
    def &(other) = other
    def |(other) = other
    def ^(other) = other
    def ~ = self
    def +@ = self
    def -@ = self
    def !@ = false
    def ~@ = self
    def [](key) = key

    def []=(key, val)
      val
    end

    def self.==(other) = other == self
    def self.<<(other) = other
  end
end
# rubocop:enable Lint/UnusedMethodArgument
