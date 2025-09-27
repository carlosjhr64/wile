# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeData class provides data about the code in a file.
  # :reek:InstanceVariableAssumption @constants @filename @index @v
  # :reek:TooManyInstanceVariables :reek:TooManyMethods
  # :reek:UncommunicativeVariableName @v
  class CodeData
    using Refinement

    attr_reader :constants, :data, :filename, :index, :responds

    KERNEL = Kernel.public_methods.map(&:to_s) + ['pp']

    # This class provides iteration variables for the CodeData class.
    IterationVariables = Struct.new(:yourself, :fullname, :prefix) do
      def dependencies = yourself.dependencies(fullname)
      def dependants = yourself.dependants(fullname)
      def external = yourself.external(fullname)
      def stdlib = yourself.stdlib(fullname)
    end

    def initialize(filename)
      vset(filename, {}, [], IterationVariables.new(self))
      @data = CodeStats.method_stats(filename) do |stat|
        [stat, stat.size, stat.category, [], [], [], []]
      end
      Responds.new do |responds|
        @responds = responds
        populate_dependencies
      end
      populate_dependants
    end

    # category: index
    def dependency_index(name, dependency) = @index["#{name}-#{dependency}"]
    # category: table
    def names              = @data.keys
    def lines(name)        = @data[name][0]
    def size(name)         = @data[name][1]
    def category(name)     = @data[name][2]
    def dependencies(name) = @data[name][3]
    def dependants(name)   = @data[name][4]
    def external(name)     = @data[name][5]
    def stdlib(name)       = @data[name][6]

    private

    def vset(*args)
      @filename, @index, @constants, @v = args
    end

    def populate_dependants
      names.permutation(2).each do |name, other|
        dependants(name) << other if dependencies(other).include?(name)
      end
    end

    CASES = {
      def_method:
        /^def\s(?<fullname>(?<prefix>[:\w]*)[.#](?<name>\w+[!=?]?|\[\]))$/x,
      method_content: /^\s\s(?<name>\S+)$/,
      method_end: /^end$/,
      casgn_const: /^casgn\s(?<fullname>[:\w]+)\s(?<type>\w+)$/x
    }.freeze
    private_constant :CASES

    # :reek:NestedIterators
    def populate_dependencies
      CodeContent.generate(@filename) do |cc|
        CASES.each do |key, rgx|
          next unless (md = rgx.match(cc))

          method(key).call(md)
          break
          # Calls:
          # def_method(md)
          # method_content(md)
          # method_end(md)
          # casgn_const(md)
        end
      end
    end

    # :reek:DuplicateMethodCall of attributes
    def add_dependency(dependency, name)
      @v.dependencies << dependency
      namex = name.namex
      key = "#{@v.fullname}-#{dependency}"
      @index[key] = lines(@v.fullname).index { namex.match? it }
    end

    def known_constant?(name, pre = @v.prefix)
      const, = name.split('.')
      ["#{pre}::#{const}", "#{pre.split('::')[0]}::#{const}", const]
        .any? { @constants.include?(it) }
    end

    def method_content(match)
      name = match[:name]
      if (dependency = get_fullname(name))
        add_dependency(dependency, name)
      else
        add_external(name) unless known_constant?(name)
      end
    end

    def get_fullname(name, pre = @v.prefix)
      if name == '.new' then ["#{pre}#initialize"]
      else
        ["#{pre}#{name}", "#{pre.split('::')[0]}::#{name}", name]
      end.each { return it if @data.key?(it) }
      nil
    end

    # :reek:DuplicateMethodCall of attributes
    def add_external(name)
      if /^[A-Z]\w*\.\w+[!=?]?$/.match?(name)
        @responds.ok?(name) ? (@v.stdlib << name) : (@v.external << name)
      elsif /^[.#]/.match?(name)
        @v.external << "#{@v.prefix}#{name}" unless KERNEL.include?(name[1..])
      else
        @v.external << name
      end
    end

    def casgn_const(match) = @constants << match[:fullname]
    def def_method(match)  = %i[prefix fullname].each { @v[it] = match[it] }
    def method_end(_)      = %i[prefix fullname].each { @v[it] = nil }
  end
end
