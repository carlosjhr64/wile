# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeContent class generates code content for the Wile framework.
  # :reek:DataClump level mdt
  # :reek:InstanceVariableAssumption there's no initialize method
  # :reek:TooManyInstanceVariables :reek:TooManyMethods
  # rubocop:disable-next Metrics/ClassLength
  class CodeContent
    using WileRefinements

    CONTENT_TYPE = {
      refine_scope: /^(?<pad>\s*)s\(:send, nil, :refine,$/,
      yield_method_name: /^\s*s\(:send, nil, :(?<name>\w+[!=?]?|\[\])/,
      invocation: /^\s*s\(:send,$/,
      method_def: /^(?<pad>\s*)s\(:def,\s+:"?(?<name>[^,"\s]+)"?,/,
      module_defs: /^(?<pad>\s*)s\(:defs,/,
      push_scope: /^(?<pad>\s*)s\(:(?<type>module|class|sclass),/,
      casgn: /^(?<pad>\s*)s\(:casgn,/
    }.freeze

    PAD = /^(?<pad>\s*)s\(/

    SCOPING = /^\s*s\(:const,$/

    CASGN_KLS = /^\s*s\(:(?<key>\w+)(?:,\s*nil,\s*:(?<kls>\w+))?/

    FULL_SCOPE = /^\s*(?:s\(:const,\snil|s\(:cbase\)|s\(:const,\ss\(:cbase\)),\s
                   (?<scp>:[A-Z]\w*\)(?<r>,\s:[A-Z]\w*\))*),
                   \s:(?<mth>[a-z]\w*[!=?]?)/x

    private_constant :CONTENT_TYPE, :PAD, :SCOPING, :CASGN_KLS, :FULL_SCOPE

    def self.generate(filename, &) = new.generate(filename, &)

    def self.ast(fnm) = Prism::Translation::Parser.parse_file(fnm).inspect.lines

    def generate(fnm, &blk)
      vset(blk, [-1], Set.new, -1, '#', nil, Set.new, [], CodeContent.ast(fnm))
      generate_content while lines_shift
      block_end
    ensure
      vset
    end

    private

    def block_end = !@dlevel.negative? && @block['end']

    def vset(*args)
      @block, @clevel, @dependencies, @dlevel,
        @dot, @line, @main, @scope, @lines = args
    end

    def lines_shift = @line = @lines.shift

    def generate_content
      content_level
      type, match = type_match
      method(type).call(match) if type
    end

    def type_match(match = nil)
      CONTENT_TYPE.first_truthy_value do |type, rgx|
        [type, match] if (match = rgx.match(@line))
      end
    end

    def content_level
      level = PAD.match(@line)[:pad].length
      definition_end if level <= @dlevel
      [@clevel, @scope].each(&:pop) while level <= @clevel.last
    end

    # :reek:FeatureEnvy :reek:NilCheck
    def casgn_kls
      while (match = CASGN_KLS.match(lines_shift))
        key = match[:key]
        kls = match[:kls]
        return kls || key unless %w[send block].include?(key) && kls.nil?
      end
    end

    def definition_end
      @dlevel = -1
      @dot = '#'
      @dependencies.clear
      @block['end']
    end

    def scope_str = @scope[0..@clevel.last].reject { it == '.' }.join('::')

    # :reek:DuplicateMethodCall :reek:UncommunicativeVariableName
    def casgn_full
      if (md = /nil,\s:(?<name>\w+)/.match(@line))
        scope_str.empty? ? md[:name] : "#{scope_str}::#{md[:name]}"
      else
        @lines.shift.scan(/:([A-Z]\w*)/).flatten.join('::')
      end
    end

    def casgn(mdt = nil, length: mdt[:pad].length)
      @block["casgn #{casgn_full} #{casgn_kls}"]
      while (head = @lines.first) && PAD.match(head)[:pad].length > length
        lines_shift
      end
    end

    # :reek:DuplicateMethodCall @lines.first on @lines.shift
    def invocation(_ = nil)
      @lines.shift while SCOPING.match?(@lines.first)
      return unless (md = FULL_SCOPE.match @lines.first)

      @lines.shift
      yield_method_name(name: "#{md[:scp].scan(/\w+/).join('::')}.#{md[:mth]}")
    end

    def yield_method_name(mdt = nil, name: "#{@dot}#{mdt[:name]}")
      if @dlevel.negative?
        @block[name] unless @main.include?(name)
        @main.add(name)
      else
        @block["  #{name}"] unless @dependencies.include?(name)
        @dependencies.add(name)
      end
    end

    def method_def(mdt = nil, level: mdt[:pad].length, name: mdt[:name])
      @dlevel = level
      @dot = @scope.last == '.' ? '.' : '#'
      @block["def #{scope_str}#{@dot}#{name}"]
    end

    def module_defs(mdt = nil, level: mdt[:pad].length)
      pattern = /^\s*s\(:self\),\s+:"?(?<name>[^,"\s]+)"?,/
      return unless (match = pattern.match(@lines.shift))

      @dlevel = level
      @dot = '.'
      @block["def #{scope_str}#{@dot}#{match[:name]}"]
    end

    def refine_scope(mdt = nil, level: mdt[:pad].length - 2)
      sclass = lines_shift if CONTENT_TYPE[:invocation].match?(@lines.first)
      push_scope(level:)
      return unless sclass

      @clevel.push level
      @scope.push '.'
    end

    # :reek:DuplicateMethodCall @lines.shift
    def push_scope(mdt = {}, level: mdt[:pad].length)
      @clevel.push level
      if mdt[:type] == 'sclass'
        @lines.shift
        @scope.push '.'
      else
        @lines.shift while SCOPING.match?(@lines.first)
        @scope.push @lines.shift.scan(/:([A-Z]\w*)/).flatten.join('::')
      end
    end
  end
end
