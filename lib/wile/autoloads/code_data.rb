# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeData class provides data about the code in a file.
  class CodeData
    attr_reader :data, :filename

    def attrs     = @meta[:attrs]
    def constants = @meta[:constants]

    def initialize(filename)
      @filename = filename
      @meta = { attrs: [], constants: [], index: {} }
      @data = CodeData.build_data(filename)
      Parser.new(self).populate
    end

    def self.build_data(filename)
      CodeStats.method_stats(filename) do |stat|
        { lines: stat, size: stat.size, category: stat.category,
          dependencies: [], dependants: [], external: [], stdlib: [] }
      end
    end

    def index = @meta[:index]

    # category: index
    def dependency_index(name, dependency) = index["#{name}-#{dependency}"]

    # Number of lines in the method:
    # category: table
    def names              = @data.keys
    def size(name)         = @data[name][:size]
    # Set by category comment, private, or defaulted to public:
    def category(name)     = @data[name][:category]
    def dependants(name)   = @data[name][:dependants]
    def dependencies(name) = @data[name][:dependencies]
    def external(name)     = @data[name][:external]
  end

  # Parses CodeContent output to populate dependencies and dependants.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class CodeData::Parser
    using WileRefinements

    # pp is autoloaded:
    KERNEL = [*Kernel.public_methods.map(&:to_s), 'pp'].freeze
    DEF_METHOD = /^def\s(?<fullname>(?<prefix>[:\w]*)[.#]\S+)$/
    METHOD_CALL = /^\s\s(?<name>\S+)$/
    CASGN_CONST = /^casgn\s(?<const>[:\w]+)\s\w+$/
    ATTR_METHOD =
      /^#attr_(?:reader|writer|accessor)\s(?<attr>[:\w]+[.#]\w+=?)$/

    private_constant :KERNEL, :DEF_METHOD, :METHOD_CALL, :CASGN_CONST,
                     :ATTR_METHOD

    def initialize(code_data)
      @code_data = code_data
      @fullname = nil
      @prefix = nil
      @responds = nil
    end

    def populate
      Responds.new do |responds|
        @responds = responds
        CodeContent.generate(@code_data.filename) { parse_content_line(it) }
      end
      populate_dependants
    end

    private

    def populate_dependants
      @code_data.names.permutation(2) do |name, other|
        @code_data.dependants(name) << other if
          @code_data.dependencies(other).include?(name)
      end
    end

    def parse_content_line(line)
      if (match = DEF_METHOD.match(line))
        @fullname = match[:fullname]
        @prefix = match[:prefix]
      elsif (match = METHOD_CALL.match(line))
        record_call(match[:name])
      elsif (match = CASGN_CONST.match(line))
        @code_data.constants << match[:const]
      elsif (match = ATTR_METHOD.match(line))
        @code_data.attrs << match[:attr]
      end
    end

    def resolve_local_method(call_name)
      candidates = if call_name == '.new' then ["#{@prefix}#initialize"]
                   else
                     ["#{@prefix}#{call_name}",
                      "#{@prefix.split('::').first}::#{call_name}", call_name]
                   end
      candidates.find { @code_data.data.key?(it) }
    end

    def record_call(call_name)
      if (dependency = resolve_local_method(call_name))
        add_dependency(dependency, call_name)
      else
        add_external(call_name) unless known_constant?(call_name)
      end
    end

    def add_dependency(dependency, call_name)
      entry = @code_data.data[@fullname]
      entry[:dependencies] << dependency
      pattern = call_name.namex
      @code_data.index["#{@fullname}-#{dependency}"] =
        entry[:lines].index { pattern.match?(it) }
    end

    def known_constant?(call_name)
      const = call_name.split('.').first
      parts = @prefix.split('::')
      parts.size.downto(0).any? do |len|
        @code_data.constants.include?([*parts[0, len], const].join('::'))
      end
    end

    def add_external(call_name)
      if call_name.start_with?('.', '#')
        add_scoped_external("#{@prefix}#{call_name}") unless
          KERNEL.include?(call_name[1..])
      else
        classify_external(call_name)
      end
    end

    def add_scoped_external(scoped_call)
      unqualified = scoped_call.split('::').last
      candidate = @responds.ok?(scoped_call) ? scoped_call : unqualified
      classify_external(scoped_call, candidate)
    end

    def classify_external(call_name, candidate = call_name)
      entry = @code_data.data[@fullname]
      if @responds.ok?(candidate)
        entry[:stdlib] << candidate
      else
        entry[:external] << call_name
      end
    end
  end
  CodeData.private_constant :Parser
end
