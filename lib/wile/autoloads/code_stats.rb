# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeStats class supplements CodeContent with method source and line counts.
  # :reek:InstanceVariableAssumption :reek:TooManyInstanceVariables
  # rubocop:disable-next Metrics/ClassLength
  class CodeStats
    MODULE_NAME = /^(?<pad>\s*)
                  (?:(?:module|class|refine)\s+(?<scope>(?:::)?\w+(?:::\w+)*)
                  (?<sclass>\.singleton_class)?|
                  (?<sclass>class\s*<<\s*self))/x
    METHOD_NAME = %r{^(?<pad>\s*)def\s+
                     (?<rcvr>(?:self|[A-Z]\w*(?:::[A-Z]\w*)*)\.)?
                     (?<name>\[\]=?|<=>|===?|!=|[!=]~|<<|>>|\*\*|[+\-!~]@|
                     [<>]=?|[+\-*/%&|^~]|\w+[!=?]?)}x
    SCOPE_END   = /^(?<pad>\s*)end$/
    CATEGORY    = /^\s*(?<cat>private|public|protected|# category: \w+)$/
    CASGN       = /^(?<pad>\s*)(?:(?<scope>[A-Z]\w*)\s*=\s*Struct\.new\b|
                  [A-Z]\w*\s*=[^=~<>])/x
    private_constant :MODULE_NAME, :METHOD_NAME, :SCOPE_END,
                     :CATEGORY, :CASGN

    # category: class_functions

    def self.method_line_count(filename) = new.method_stats(filename, &:size)

    def self.method_source(filename) = new.method_stats(filename) { it }

    def self.method_stats(filename, &) = new.method_stats(filename, &)

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
      return unless (@line = @lines.shift)

      @source << @line
    end

    # :reek:TooManyStatements
    def method_name(match)
      rcvr = match[:rcvr]
      return if !rcvr && /^\s*def\s+\S+\./.match?(@line)

      dot = @scope.last == '.' || rcvr ? '.' : '#'
      @dlevel = match[:pad].length
      @name = "#{def_scope(rcvr)}#{dot}#{match[:name]}"
      @source = CodeStats.source(@source[-1..])
      @source.category @category
      @hash[@name] = @func[@source]
    end

    def def_scope(rcvr)
      return scope_str unless rcvr && rcvr != 'self.'

      named = rcvr.delete_suffix('.')
      return scope_str if scope_str.split('::').last == named
      return named if scope_str.empty? || named.start_with?(scope_str)

      "#{scope_str}::#{named}"
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

    def casgn(match, length = match[:pad].length)
      if (scope = match[:scope])
        lines_shift until /\bdo\s*$|\)\s*$/.match?(@line) || @lines.empty?
        level_push(length, scope) if /\bdo\s*$/.match?(@line)
      else
        lines_shift while @lines[0]&.match?(/\A(?:\s*$|\s{#{length + 1}})/)
      end
    end

    def msh_populate
      if (match = MODULE_NAME.match(@line)) then module_name(match)
      elsif (match = METHOD_NAME.match(@line)) then method_name(match)
      elsif (match = SCOPE_END.match(@line)) then scope_end(match)
      elsif (match = CATEGORY.match(@line)) then category_set(match)
      elsif (match = CASGN.match(@line)) then casgn(match)
      end
    end

    def scope_str = @scope.reject { it == '.' }.join('::')

    def category_set(match)
      @category = "#{scope_str}.#{match[:cat].split.last}"
    end

    def scope_end(match)
      length = match[:pad].length
      if @name && @dlevel == length then source_set
      else
        level_pops while @clevel.last >= length
      end
    end

    def module_name(match)
      pad, scope, sclass = match.values_at(:pad, :scope, :sclass)
      len = pad.length
      level_push(len, scope) if scope
      level_push(len, '.') if sclass
    end

    def level_pops = [@clevel.pop, @scope.pop]

    def level_push(pad, scope)
      @clevel.push(pad)
      @scope.push(scope)
      @category = "#{scope_str}.public" unless scope == '.'
    end
  end
end
