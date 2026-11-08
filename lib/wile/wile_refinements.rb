# frozen_string_literal: true

# Wile namespace.
module Wile
  # Utility methods for the Wile project.
  module WileRefinements
    # category: array

    refine Array do
      # :reek:TooManyStatements
      # :reek:DuplicateMethodCall it.to_s
      def display(width: `tput cols 2>/dev/null`.to_i, padding: 2, io: $stdout)
        return if empty?

        max = map { it.to_s.length }.max + padding
        div = width / max
        div = 1 if div.zero?
        each_slice(div) do |slice|
          io.puts slice.map { it.to_s.ljust(max) }.join
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

    # category: kernel

    refine Kernel do
      # :reek:UncommunicativeMethodName system2
      def system2(string)
        warn string.blue
        system(string)
      end
    end

    # category: object

    refine Object do
      def as
        yield self
      end
    end

    # category: string

    refine String do
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
