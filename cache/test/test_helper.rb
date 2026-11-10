# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8

require 'test/unit'
require 'colorize'
require 'prism'
# wile: require 'reek'
# wile: require 'rubocop'

String.disable_colorization = true unless $stdout.tty? &&
                                          ENV['NO_COLOR'].to_s.empty? &&
                                          ENV['TERM'] != 'dumb'

# :reek:IrresponsibleModule
module Test
  # :reek:IrresponsibleModule
  module Unit
    # Shared test case helpers for unit tests.
    # :reek:IrresponsibleModule
    class TestCase
      FAULT_ONLY = ARGV.include?('--progress-style=fault-only')

      # :reek:UtilityFunction
      def bang_ruby?(filename)
        return false if /\.\w*$/.match?(filename) ||
                        File.directory?(filename) ||
                        File.empty?(filename) ||
                        !File.executable?(filename)

        /^#!.*\bruby\b/.match?(File.read(filename, 80).lines[0].rstrip)
      end

      # :reek:UtilityFunction
      def binary?(filename)
        File.open(filename, 'rb') { |io| io.read(8192)&.include?("\x00") }
      end

      # wile: os `diff`
      # :reek:UtilityFunction
      def diff_output(source_file, target_file)
        cmd = String.disable_colorization ? 'diff' : 'diff --color=always'
        `#{cmd} #{source_file} #{target_file}`.strip
      end

      # :reek:UtilityFunction
      def quiet? = FAULT_ONLY

      # :reek:UtilityFunction
      def ruby?(filename)
        /\.rb$/.match?(filename) || bang_ruby?(filename)
      end

      def ruby_files
        `git ls-files`.lines.map(&:chomp)
                      .select { File.file?(it) }
                      .select { ruby?(it) }
      end

      # :reek:TooManyStatements
      # :reek:UtilityFunction
      def strip_comments(source)
        clean = source.dup
        Prism.parse_comments(source).reverse_each do |comment|
          loc = comment.location
          blank = loc.slice.gsub(/[^\r\n]/, ' ')
          clean.bytesplice(loc.start_offset, loc.length, blank)
        end
        clean
      end
    end
  end
end

# Shared helpers for unit tests in Wile projects. Verifies that every
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
#       rubocop(__FILE__) # self rubocop-ing
#     end
#   end

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
      public: :yellow,
      protected: :yellow,
      private: :yellow,
      refinement: :yellow
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
        .sub(/\[\]=$/, 'brackets_set')
        .sub(/\[\]$/, 'brackets')
        .sub(/<<$/, 'shovel')
        .sub(/<=>$/, 'spaceship')
        .sub(/==$/, 'equals')
        .sub(/=$/, '_set')
        .sub(/!$/, '_bang')
        .sub(/\?$/, '_predicate')
    end
    private_constant :RENAME

    # Check if context has a test for the method.
    # :reek:ManualDispatch
    def test_method(method, type, mod = '')
      return if method.start_with? 'test_'

      name = RENAME["#{mod}#{method}"]
      return if name.end_with?('?_set') || covered?(name, mod, method)

      puts "Missing #{@context.class}##{name}".colorize COLOR[type]
    end

    def covered?(name, mod, method)
      return true if test_exists?(name)

      method.end_with?('?') &&
        test_exists?("test_#{mod}#{method}".sub(/\?$/, '_wut'))
    end

    # :reek:ManualDispatch
    def test_exists?(name)
      return true if @context.respond_to?(name.to_sym)

      @context.methods.any? { it.to_s.start_with?("#{name}_") }
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
