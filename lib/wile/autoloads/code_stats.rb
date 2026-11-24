# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeStats supplements CodeContent with method source and line counts.
  class CodeStats
    # :reek:UtilityFunction
    def method_stats(filename, &func)
      Scanner.new(File.readlines(filename), func, ScopeTracker.new).scan
    end

    def self.method_line_count(filename) = new.method_stats(filename, &:size)

    def self.method_source(filename) = new.method_stats(filename) { it }

    def self.method_stats(filename, &) = new.method_stats(filename, &)

    def self.source(source = [])
      def source.category(cat = nil)
        cat ? @category = cat : @category
      end
      source
    end
  end

  # Tracks lexical scope, indentation levels, and method categories.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class CodeStats::ScopeTracker
    attr_reader :category

    def initialize
      @clevel = [-1]
      @scope = []
      @category = '.public'
    end

    def pop_to(length)
      while @clevel.last >= length
        @clevel.pop
        @scope.pop
      end
    end

    def push(pad, scope)
      @clevel.push(pad)
      @scope.push(scope)
      @category = "#{scope_str}.public" unless scope == '.'
    end

    def scope_str = @scope.reject { it == '.' }.join('::')

    def update_category(cat) = @category = "#{scope_str}.#{cat.split.last}"

    def method_name(rcvr, name)
      dot = @scope.last == '.' || rcvr ? '.' : '#'
      "#{def_scope(rcvr)}#{dot}#{name}"
    end

    private

    def def_scope(rcvr)
      return scope_str unless rcvr && rcvr != 'self.'

      named = rcvr.delete_suffix('.')
      return scope_str if scope_str.split('::').last == named
      return named if scope_str.empty? || named.start_with?(scope_str)

      "#{scope_str}::#{named}"
    end
  end

  # Scans Ruby source lines to collect per-method source arrays and categories.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class CodeStats::Scanner
    MATCHERS = {
      /^(?<pad>\s*)
       (?:(?:module|class|refine)\s+(?<scope>(?:::)?\w+(?:::\w+)*)
       (?<sclass>\.singleton_class)?|
       (?<sclass>class\s*<<\s*self))/x => :module_name,
      %r{^(?<pad>\s*)def\s+
         (?<rcvr>(?:self|[A-Z]\w*(?:::[A-Z]\w*)*)\.)?
         (?<name>\[\]=?|<=>|===?|!=|[!=]~|<<|>>|\*\*|[+\-!~]@|
         [<>]=?|[+\-*/%&|^~]|\w+[!=?]?)}x => :method_name,
      /^(?<pad>\s*)end$/ => :scope_end,
      /^\s*(?<cat>private|public|protected|# category: \w+)$/ => :category_set,
      /^(?<pad>\s*)(?:(?<scope>[A-Z]\w*)\s*=\s*Struct\.new\b|
       [A-Z]\w*\s*=[^=~<>])/x => :casgn
    }.freeze
    ENDLESS_DEF = /\A\s*def\s+[^\s(]+(?:\([^)]*\))?\s+=\s/
    private_constant :MATCHERS, :ENDLESS_DEF

    def initialize(lines, func, tracker)
      @lines = lines
      @func = func
      @tracker = tracker
      @state = { hash: {}, dlevel: 0, name: nil, line: nil,
                 source: CodeStats.source }
    end

    def scan
      msh_populate while lines_shift
      @state[:hash]
    end

    private

    def reset_method
      @state[:dlevel] = 0
      @state[:name] = nil
      @state[:source] = CodeStats.source
    end

    def method_name(match)
      rcvr = match[:rcvr]
      return if !rcvr && /^\s*def\s+\S+\./.match?(@state[:line])

      name = @tracker.method_name(rcvr, match[:name])
      source = CodeStats.source(@state[:source][-1..])
      store_method(name, match[:pad].length, source)
    end

    def msh_populate
      MATCHERS.each do |pattern, handler|
        next unless (match = pattern.match(@state[:line]))

        return send(handler, match)
      end
    end

    def lines_shift
      return unless (line = @lines.shift)

      @state[:line] = line
      @state[:source] << line
    end

    def store_method(name, dlevel, source)
      source.category(@tracker.category)
      @state.merge!(dlevel:, name:, source:)
      @state[:hash][name] = @func[source]
      reset_method if ENDLESS_DEF.match?(@state[:line])
    end

    def finish_method
      src = @state[:source]
      src.pop
      src.category(@tracker.category)
      @state[:hash][@state[:name]] = @func[src]
      reset_method
    end

    def casgn(match, length = match[:pad].length)
      if (scope = match[:scope])
        lines_shift until /\bdo\s*$|\)\s*$/.match?(@state[:line]) ||
                          @lines.empty?
        push_struct_scope(length, scope)
      else
        lines_shift while @lines[0]&.match?(/\A(?:\s*$|\s{#{length + 1}})/)
      end
    end

    def push_struct_scope(length, scope)
      @tracker.push(length, scope) if /\bdo\s*$/.match?(@state[:line])
    end

    def scope_end(match)
      length = match[:pad].length
      if @state[:name] && @state[:dlevel] == length
        finish_method
      else
        @tracker.pop_to(length)
      end
    end

    def category_set(match) = @tracker.update_category(match[:cat])

    def module_name(match)
      pad, scope, sclass = match.values_at(:pad, :scope, :sclass)
      len = pad.length
      @tracker.push(len, scope) if scope
      @tracker.push(len, '.') if sclass
    end
  end
  CodeStats.private_constant :ScopeTracker, :Scanner
end
