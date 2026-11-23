# frozen_string_literal: true

# wile: os `tput`

# Wile namespace.
module Wile
  # Utility methods for the Wile project.
  module WileRefinements
    COMMON_CLASSES = [
      String, Array, Hash, File, Set, Pathname, Time, Exception, Method,
      Enumerator, Thread
    ].freeze
    SYM_OP = %r{[-=!<>&|*+%/^~]}
    ANSI_SGR = /\e\[[0-9;]*m/
    private_constant :COMMON_CLASSES, :SYM_OP, :ANSI_SGR

    def self.measure_items(list)
      list.map do |item|
        str = item.to_s
        [str, str.gsub(ANSI_SGR, '').length]
      end
    end

    def self.format_row(slice, max)
      slice.map { |str, size| "#{str}#{' ' * (max - size)}" }.join
    end

    def self.format_columns(list, width, padding)
      items = measure_items(list)
      max = items.map(&:last).max + padding
      div = [width / max, 1].max
      items.each_slice(div).map { format_row(it, max) }
    end

    def self.word_regexp(name)
      tail = name[-1]
      return /\b#{Regexp.escape(name)}\b/ unless '!=?'.include?(tail)

      /\b#{Regexp.escape(name[...-1])}[#{tail}]/
    end

    def self.name_regexp(raw)
      name = raw.sub(/\A[#.]/, '')
      return /\[\s*\]#{'=' if name == '[]='}/ if ['[]', '[]='].include?(name)
      return /(?<!#{SYM_OP})#{Regexp.escape(name)}(?!#{SYM_OP})/ unless
        name.match?(/\w/)

      word_regexp(name)
    end

    # category: array

    refine Array do
      def display(width: `tput cols 2>/dev/null`.to_i, padding: 2, io: $stdout)
        return if empty?

        WileRefinements.format_columns(self, width, padding).each { io.puts it }
      end

      def unique = length == 1 ? first : nil
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
        regexp.match(read(filename)) or raise "no match: #{regexp} #{filename}"
      end

      def sub!(filename, regexp, sub)
        string = read(filename).sub!(regexp, sub)
        write(filename, string) if string
      end
    end

    # category: object

    refine Object do
      def as = yield self
    end

    # category: string

    refine String do
      # Converts a method name string into a Regexp to match its occurrence
      # in Ruby source code lines (e.g. definitions, calls, or operators).
      def namex = WileRefinements.name_regexp(self)

      def object_method?
        sym = split(/[#.]/).last&.to_sym
        return false unless sym

        sym != :new && Object.methods.include?(sym)
      end

      def common_ruby_method_name?
        return true if object_method?

        name = split(/[#.]/).last
        return false unless name

        COMMON_CLASSES.any? { it.public_method_defined?(name) }
      end

      def name_split = split(/[_-]|(?=[A-Z])/)

      def pascal_case = name_split.map(&:capitalize).join
      alias_method :title_case, :pascal_case

      def snake_case(str = '_') = name_split.map(&:downcase).join(str)

      def camel_case = pascal_case.tap { it[0] = it[0].downcase }

      def kebab_case = snake_case('-')

      def standard_library?
        lib = sub(/\A::/, '').split(/::|[#.]/).first&.downcase
        return false unless lib&.match?(/\A[a-z]\w*\z/)

        RbConfig::CONFIG.values_at('rubylibdir', 'archdir')
                        .product(["#{lib}.rb", "#{lib}.so", lib])
                        .any? { File.exist?(File.join(*it)) } ||
          Gem::Specification.any? { it.default_gem? && it.name == lib }
      end
    end
  end
end
