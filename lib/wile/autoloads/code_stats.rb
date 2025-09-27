# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeStats class supplements CodeContent with method source and line counts.
  # :reek:InstanceVariableAssumption :reek:TooManyInstanceVariables
  class CodeStats
    def initialize
      # Nothing to do here
    end

    # category: class_functions

    def self.method_line_count(filename)
      new.method_stats(filename, &:size)
    end

    def self.method_source(filename)
      new.method_stats(filename) { it }
    end

    def self.method_stats(filename, &)
      new.method_stats(filename, &)
    end

    def self.source(source = [])
      def source.category(cat = nil)
        cat ? @category = cat : @category
      end
      source
    end

    # category: class_methods

    def method_stats(filename, &func)
      content_initialize(func) { File.readlines(filename) }
      msh_populate while lines_shift
      @hash
    ensure
      vset
    end

    private

    def content_initialize(func)
      vset(func, yield, '.public', [-1], 0, {}, nil, nil, [], CodeStats.source)
    end

    def vset(*args)
      @func, @lines, @category, @clevel, @dlevel,
        @hash, @line, @name, @scope, @source = args
    end

    def lines_shift
      (@line = @lines.shift) ? (@source << @line) : nil
    end

    # :reek:DuplicateMethodCall slf.nil :reek:NilCheck
    # :reek:TooManyStatements
    def method_name(match)
      slf = match[:slf] # Skip named defs
      return if slf.nil? && /^\s*def\s+\w+\./.match?(@line)

      slf = slf.nil? ? '#' : '.'
      @dlevel = match[:pad].length
      @name = "#{@scope.join('::')}#{slf}#{match[:name]}"
      @source = CodeStats.source(@source[-1..])
      @source.category @category
      @hash[@name] = @func[@source]
    end

    # :reek:TooManyStatements
    def source_set
      @source.pop
      @source.category @category
      @hash[@name] = @func[@source]
      @dlevel = 0
      @name = nil
      @source = CodeStats.source
    end

    # :reek:UncommunicativeVariableName
    def casgn(length)
      lines_shift while (l = @lines[0]) && (l.strip.empty? ||
                        /^(?<p>\s*)/.match(l)[:p].length > length)
    end

    MODULE_NAME = /^(?<pad>\s*)(?<_>module|class)\s+(?<scope>\w+)/
    METHOD_NAME = /^(?<pad>\s*)def\s+(?<slf>self\.)?(?<name>\w+[!=?]?|\[\])/
    SCOPE_END   = /^(?<pad>\s*)end$/
    CATEGORY    = /^\s*(?<cat>private|public|protected|# category: \w+)$/
    CASGN       = /^(?<pad>\s*)[A-Z]\w*\s*=[^=~<>]/
    private_constant :MODULE_NAME, :METHOD_NAME, :SCOPE_END, :CATEGORY, :CASGN

    # :reek:UncommunicativeVariableName
    def msh_populate
      if (m = MODULE_NAME.match @line) then module_name(m)
      elsif (m = METHOD_NAME.match @line) then method_name(m)
      elsif (m = SCOPE_END.match @line) then scope_end(m)
      elsif (m = CATEGORY.match @line) then category_set(m)
      elsif (m = CASGN.match @line) then casgn(m[:pad].length)
      end
    end

    def category_set(match)
      @category = match[:cat].split.last
      @category = "#{@scope.join('::')}.#{@category}"
    end

    def scope_end(match)
      length = match[:pad].length
      if @name && @dlevel == length then source_set
      else
        level_pops while @clevel.last >= length
      end
    end

    def module_name(match)
      @clevel.push match[:pad].length
      @scope.push match[:scope]
      @category = "#{@scope.join('::')}.public"
    end

    def level_pops
      @clevel.pop
      @scope.pop
    end
  end
end
