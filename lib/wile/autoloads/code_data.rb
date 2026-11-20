# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeData class provides data about the code in a file.
  # :reek:TooManyInstanceVariables :reek:TooManyMethods
  # rubocop:disable-next Metrics/ClassLength
  class CodeData
    using WileRefinements

    attr_reader :attrs, :constants, :data, :filename, :index

    # :reek:TooManyStatements
    def initialize(filename)
      @filename = filename
      @attrs = []
      @constants = []
      @index = {}
      @fullname = @prefix = @responds = nil
      @data = build_data(filename)
      populate_dependencies
      populate_dependants
    end

    # category: index
    def dependency_index(name, dependency) = @index["#{name}-#{dependency}"]

    # Number of lines in the method:
    # category: table
    def size(name)         = @data[name][:size]
    # Set by category comment, private, or defaulted to public:
    def category(name)     = @data[name][:category]
    def names              = @data.keys
    def dependants(name)   = @data[name][:dependants]
    def external(name)     = @data[name][:external]
    def dependencies(name) = @data[name][:dependencies]

    private

    def stdlib(name) = @data[name][:stdlib]
    # Source/Code lines of the method:
    def lines(name)  = @data[name][:lines]

    # category: populate

    # :reek:UtilityFunction
    def build_data(filename)
      CodeStats.method_stats(filename) do |stat|
        { lines: stat, size: stat.size, category: stat.category,
          dependencies: [], dependants: [], external: [], stdlib: [] }
      end
    end

    # pp is autoloaded:
    KERNEL = [*Kernel.public_methods.map(&:to_s), 'pp'].freeze
    DEF_METHOD = /^def\s(?<fullname>(?<prefix>[:\w]*)[.#](?:\w+[!=?]?|\[\]))$/
    METHOD_CALL = /^\s\s(?<name>\S+)$/
    CASGN_CONST = /^casgn\s(?<const>[:\w]+)\s\w+$/
    ATTR_METHOD =
      /^#attr_(?:reader|writer|accessor)\s(?<attr>[:\w]+[.#]\w+=?)$/

    private_constant :KERNEL, :DEF_METHOD, :METHOD_CALL, :CASGN_CONST,
                     :ATTR_METHOD

    def populate_dependants
      names.permutation(2) do |name, other|
        dependants(name) << other if dependencies(other).include?(name)
      end
    end

    def populate_dependencies
      Responds.new do |responds|
        @responds = responds
        CodeContent.generate(@filename) { parse_content_line(it) }
      end
    end

    def classify_external(call_name, candidate = call_name)
      if @responds.ok?(candidate)
        stdlib(@fullname) << candidate
      else
        external(@fullname) << call_name
      end
    end

    def add_dependency(dependency, call_name)
      dependencies(@fullname) << dependency
      pattern = call_name.namex
      key = "#{@fullname}-#{dependency}"
      @index[key] = lines(@fullname).index { pattern.match?(it) }
    end

    def add_scoped_external(scoped_call)
      unqualified = scoped_call.split('::').last
      candidate = @responds.ok?(scoped_call) ? scoped_call : unqualified
      classify_external(scoped_call, candidate)
    end

    def add_external(call_name)
      if call_name.start_with?('.', '#')
        add_scoped_external("#{@prefix}#{call_name}") unless
          KERNEL.include?(call_name[1..])
      else
        classify_external(call_name)
      end
    end

    def parse_content_line(line)
      if (match = DEF_METHOD.match(line))
        @fullname = match[:fullname]
        @prefix = match[:prefix]
      elsif (match = METHOD_CALL.match(line))
        record_call(match[:name])
      elsif (match = CASGN_CONST.match(line))
        @constants << match[:const]
      elsif (match = ATTR_METHOD.match(line))
        @attrs << match[:attr]
      end
    end

    def record_call(call_name)
      if (dependency = resolve_local_method(call_name))
        add_dependency(dependency, call_name)
      else
        add_external(call_name) unless known_constant?(call_name)
      end
    end

    def resolve_local_method(call_name)
      candidates = if call_name == '.new' then ["#{@prefix}#initialize"]
                   else
                     ["#{@prefix}#{call_name}",
                      "#{@prefix.split('::').first}::#{call_name}", call_name]
                   end
      candidates.find { @data.key?(it) }
    end

    def known_constant?(call_name)
      const = call_name.split('.').first
      return true if @constants.include?(const)

      suffix = "::#{const}"
      @constants.any? do |full_const|
        full_const.end_with?(suffix) &&
          @prefix.start_with?(full_const.delete_suffix(suffix))
      end
    end
  end
end
