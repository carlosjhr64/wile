# frozen_string_literal: true

# Namespace: Wile
module Wile
  # Categorizes methods
  class Smell
    attr_reader :known_constants, :methods, :undefined_methods

    # This struct keeps information about a method.
    Info = Struct.new(:filename, :dependencies, :dependants, :external)

    def initialize(dir = 'lib')
      @methods = {}
      @known_constants = Set.new
      @undefined_methods = Set.new
      get_code_data(dir)
      add_undefined_methods
    end

    private

    # :reek:TooManyStatements
    def get_code_data(dir)
      Find.find(dir) do |filename|
        next unless /\.rb$/.match?(filename)

        cdt = CodeData.new(filename)
        cdt.constants.each { @known_constants << it }
        cdt.names.each { @methods[it] = info(cdt, filename, it) }
      end
    end

    # :reek:UtilityFunction :reek:TooManyStatements
    def info(cdt, filename, name)
      dependencies = cdt.dependencies(name).empty? ? [] : [filename]
      dependants = cdt.dependants(name).empty? ? [] : [filename]
      external = cdt.external(name)
      Info.new(filename, dependencies, dependants, external)
    end

    # :reek:FeatureEnvy
    def add(selected, info)
      selected_info = @methods[selected]
      info.dependencies << selected_info.filename
      selected_info.dependants << info.filename
    end

    # :reek:UncommunicativeVariableName m is method
    def add_undefined_methods
      @methods.each do |name, info|
        next if (external = info.external).empty?

        while (m = external.shift)
          if (selected = selected_method(m, name)) then add(selected, info)
          else
            @undefined_methods << m unless known_constant?(m, name)
          end
        end
      end
    end

    def known_constant?(const_dot_mth, name)
      scope, = name.split(/[.#]/)
      mod = scope.split('::').first
      const, = const_dot_mth.split('.')
      ["#{scope}::#{const}", "#{mod}::#{const}", const]
        .any? { @known_constants.include?(it) }
    end

    def selected_method(mth, name)
      mth = mth.sub(/\.new$/, '#initialize')
      return nil if (names = @methods.keys.select { it.end_with?(mth) }).empty?

      names.detect do |candidate|
        candidate == mth || name.start_with?(candidate.sub(mth, ''))
      end
    end
  end
end
