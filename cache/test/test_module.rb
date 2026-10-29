# frozen_string_literal: true

# Shared helpers for unit tests in scaffolded projects. Verifies that every
# method on a target class has a corresponding test method (method-level
# coverage audit) and provides no-fail wrappers for running linters on files.
#
# Suggested template usage:
#
#   class TestMyClass < Test::Unit::TestCase
#     include TestModule
#
#     def test_coverage = coverage(MyClass)
#
#     # And unit test methods...
#
#     def test_rubocop_and_reek
#       file = 'lib/my_class.rb'
#       rubocop(file) &&  # but redundant by tc_rubocop
#       reek(file) &&     # but redundant by tc_reek
#       rubocop(__FILE__) # self robocop-ing
#     end
#   end

require 'test/unit'
require 'colorize'
# Also:
# require 'reek'
# require 'rubocop'

module MissingCalls
  def missing_calls = (@missing_calls ||= [])

  # rubocop:disable-next Style/MissingRespondToMissing
  def method_missing(*args)
    missing_calls.push(args)
    self
  end
end

# :reek:IrresponsibleModule
module MockUp
  # :reek:TooManyStatements
  def self.create(mod, symbol)
    klass = Class.new do
      include MissingCalls

      def initialize(*) = nil
      def inspect = self.class.to_s
    end
    klass.extend MissingCalls
    mod.const_set(symbol, klass)
  end
end

# Test and warnings common to test files
module TestModule
  # Checks for context.test_method for each klass.method
  class Coverage
    # Allow color changes.
    # rubocop:disable-next Style/MutableConstant
    COLOR = {
      public: :red,
      protected: :light_red,
      private: :magenta,
      refinement: :cyan
    }

    def initialize(klass, context)
      @klass = klass
      @context = context
    end

    # :reek:ControlParameter
    def test_all(klass_methods)
      test_class_methods if klass_methods
      test_public_methods
      test_protected_methods
      test_private_methods
      test_refinements
    end

    def test_class_methods
      @klass.methods(false).sort.each do |method|
        test_method method, :public, 'class_'
      end
    end

    def test_public_methods
      @klass.public_instance_methods(false).sort.each do |method|
        test_method method, :public
      end
    end

    def test_protected_methods
      @klass.protected_instance_methods(false).sort.each do |method|
        test_method method, :protected
      end
    end

    def test_private_methods
      @klass.private_instance_methods(false).sort.each do |method|
        test_method method, :private
      end
    end

    def test_refinements
      @klass.refinements.each do |refinement|
        test_refinement refinement, refinement.target.to_s.downcase
      end
    end

    private

    RENAME = lambda do |method|
      "test_#{method}"
        .sub(/=$/, '_set')
        .sub(/!$/, '_bang')
        .sub(/\?$/, '_wut')
    end
    private_constant :RENAME

    # Check if context has a test for the method.
    # :reek:ManualDispatch
    def test_method(method, type, mod = '')
      return if method.start_with? 'test_'

      name = RENAME["#{mod}#{method}"]
      return if name.end_with? '?_set'
      return if @context.respond_to? name.to_sym

      puts "Missing #{@context.class}##{name}".colorize COLOR[type]
    end

    def test_refinement(refinement, target)
      refinement.public_instance_methods(false).each do |method|
        test_method "#{target}_#{method}", :refinement
      end
    end
  end

  # No fail warnings
  # :reek:BooleanParameter
  def coverage(klass, klass_methods: true)
    Coverage.new(klass, self).test_all(klass_methods)
  end

  # No fail system runs

  def reek(file)
    puts "Reek #{file}".blue
    system('reek', file)
  end

  def rubocop(file)
    puts "Rubocop #{file}".blue
    system('rubocop', file)
  end
end
