# frozen_string_literal: true

# Wile namespace.
module Wile
  # Utility methods for the Wile project.
  module WileRefinements
    # category: array

    refine Array do
      # :reek:TooManyStatements :reek:NestedIterators
      # :reek:DuplicateMethodCall it.to_s
      # rubocop:disable-next Metrics/AbcSize
      def display(width: `tput cols 2>/dev/null`.to_i, padding: 2, io: $stdout)
        return if empty?

        items = map { [it.to_s, it.to_s.gsub(/\e\[[0-9;]*m/, '').length] }
        max = items.map(&:last).max + padding
        div = [width / max, 1].max
        items.each_slice(div) do |slice|
          io.puts slice.map { |str, size| "#{str}#{' ' * (max - size)}" }.join
        end
      end

      def unique
        length == 1 ? first : nil
      end
    end

    # category: enumerable

    refine Enumerable do
      def first_truthy_value
        each { (truthy = yield it) and return truthy }
        nil
      end
    end

    # category: file

    refine File.singleton_class do
      # Matches a regexp against file contents, raising if no match is found.
      def match!(filename, regexp)
        regexp.match File.read(filename) or
          raise "no match: #{regexp} #{filename}"
      end

      # :reek:UtilityFunction
      def sub!(filename, regexp, sub)
        string = File.read(filename).sub!(regexp, sub)
        File.write(filename, string) if string
      end
    end

    # category: object

    refine Object do
      def as
        yield self
      end
    end

    COMMON_CLASSES = [
      String, Array, Hash, Enumerable, Enumerator, IO
    ].freeze
    private_constant :COMMON_CLASSES

    # category: string

    refine String do
      # :reek:ManualDispatch
      def object_method?
        name = split(/[#.]/).last
        return false unless name

        name != 'new' && Object.respond_to?(name)
      end

      def common_ruby_method_name?
        return true if object_method?

        name = split(/[#.]/).last
        return false unless name

        COMMON_CLASSES.any? { it.public_method_defined?(name) }
      end

      def standard_library?
        lib = sub(/\A::/, '').split(/::|[#.]/).first&.downcase
        return false unless lib&.match?(/\A[a-z]\w*\z/)

        RbConfig::CONFIG.values_at('rubylibdir', 'archdir')
                        .product(["#{lib}.rb", "#{lib}.so", lib])
                        .any? { File.exist?(File.join(*it)) } ||
          Gem::Specification.any? { it.default_gem? && it.name == lib }
      end

      def camel_case
        pascal_case.tap { it[0] = it[0].downcase }
      end

      def pascal_case
        name_split.map(&:capitalize).join
      end
      alias_method :title_case, :pascal_case

      def name_split
        split(/[_-]|(?=[A-Z])/)
      end

      def snake_case(str = '_')
        name_split.map(&:downcase).join(str)
      end

      def kebab_case
        snake_case('-')
      end

      # Converts a method name string into a Regexp to match its occurrence
      # in Ruby source code lines (e.g. definitions, calls, or operators).
      # :reek:FeatureEnvy :reek:TooManyStatements
      # :reek:DuplicateMethodCall nme[-1]
      def namex
        nme = start_with?('#', '.') ? self[1..] : self
        return /\[\s*\]#{'=' if nme == '[]='}/ if ['[]', '[]='].include?(nme)

        sym = %r{[-=!<>&|*+%/^~]}
        return /(?<!#{sym})#{Regexp.escape(nme)}(?!#{sym})/ unless
          nme.match?(/\w/)

        if '!=?'.include?(nme[-1])
          /\b#{Regexp.escape(nme[...-1])}[#{nme[-1]}]/
        else
          /\b#{Regexp.escape(nme)}\b/
        end
      end
    end
  end
end
