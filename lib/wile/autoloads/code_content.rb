# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeContent class generates code content for the Wile framework.
  # :reek:DataClump level mdt
  # :reek:InstanceVariableAssumption there's no initialize method
  # :reek:TooManyInstanceVariables
  class CodeContent
    using Refinement

    CONTENT_TYPE = {
      yield_method_name: /^\s*s\(:send, nil, :(?<name>\w+[!=?]?|\[\])/,
      invocation: /^\s*s\(:send,$/,
      method_def: /^(?<pad>\s*)s\(:def, :(?<name>\w+[!=?]?|\[\])/,
      module_defs: /^(?<pad>\s*)s\(:defs,/,
      push_scope: /^(?<pad>\s*)s\(:(?<_>module|class),/,
      casgn: /^(?<pad>\s*)s\(:casgn, nil, :(?<name>\w+)/
    }.freeze

    PAD = /^(?<pad>\s*)s\(/

    SCOPING = /^\s*s\(:const,$/

    FULL_SCOPE = /^\s*s\(:const,\snil,\s
                   (?<scp>:[A-Z]\w*\)(?<r>,\s:[A-Z]\w*\))*),
                   \s:(?<mth>[a-z]\w*[!=?]?)/x

    private_constant :CONTENT_TYPE, :PAD, :SCOPING, :FULL_SCOPE

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

    def block_end = @dlevel.positive? && @block['end']

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

    # :reek:DuplicateMethodCall lines_shift is shifting lines
    # :reek:NilCheck
    def casgn_kls
      _, key, _, kls = lines_shift.scan(/\w+/)
      while kls.nil? && %w[send block].include?(key)
        _, key, _, kls = lines_shift.scan(/\w+/)
      end
      kls || key
    end

    def definition_end
      @dlevel = -1
      @dot = '#'
      @dependencies.clear
      @block['end']
    end

    def casgn(mdt = nil, length: mdt[:pad].length, name: mdt[:name])
      kls = casgn_kls
      @block["casgn #{@scope[0..@clevel.last].join('::')}::#{name} #{kls}"]
      while !@lines.empty? && PAD.match(@lines.first)[:pad].length > length
        @line = @lines.shift
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
      @dot = '#'
      @block["def #{@scope[0..@clevel.last].join('::')}#{@dot}#{name}"]
    end

    # :reek:NilCheck
    def module_defs(mdt = nil, level: mdt[:pad].length)
      slf, name, wut = @lines.shift.scan(/:\w+[!=?]?|:\[\]/)
      return unless wut.nil? && slf == ':self'

      @dlevel = level
      @dot = '.'
      @block["def #{@scope[0..@clevel.last].join('::')}#{@dot}#{name[1..]}"]
    end

    def push_scope(mdt = nil, level: mdt[:pad].length)
      @clevel.push level
      @scope.push @lines.shift.scan(/\w+/)[3]
    end
  end
end
