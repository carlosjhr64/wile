# frozen_string_literal: true

# :reek:IrresponsibleModule :reek:TooManyConstants
module SampleConstants
  LAMBDA = ->(num) { num + 1 }
  STR = 'hello'
  TEXT = 'multi word string'
  RATE = 3.14
  COUNT = 42
  MAP = { a: 1 }.freeze
  REGEX = /^\w+$/
  LIST = [1, 2].freeze
  STATUS = :active
  Pair = Struct.new(:a, :b)
  CUSTOM = Object.new
end
