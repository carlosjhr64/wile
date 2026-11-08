# frozen_string_literal: true

# Namespace: Wile
module Wile
  # Categorizes methods
  class Smell
    attr_reader :known_constants, :methods, :undefined_methods

    # This struct keeps information about a method.
    Info = Struct.new(:filename, :dependencies, :dependants, :external) do
      def initialize(cdt, name)
        super(cdt.filename, [], [], cdt.external(name))
        dependencies << filename unless cdt.dependencies(name).empty?
        dependants << filename unless cdt.dependants(name).empty?
      end

      def add_dependency(other)
        dependencies << other.filename
        other.dependants << filename
      end
    end
    private_constant :Info

    def initialize(dir = 'lib')
      @methods = {}
      @known_constants = Set.new
      @undefined_methods = Set.new
      get_code_data(dir)
      @methods.each { |name, info| add_undefined_methods(name, info) }
    end

    private

    def get_code_data(dir)
      Find.find(dir).grep(/\.rb$/) do |filename|
        cdt = CodeData.new(filename)
        @known_constants.merge(cdt.constants)
        cdt.names.each { @methods[it] = Info.new(cdt, it) }
      end
    end

    def selected_method(mth, name)
      target = mth.sub(/\.new$/, '#initialize')
      @methods.each_key
              .select { it.end_with?(target) }
              .detect { name.start_with?(it.delete_suffix(target)) }
    end

    def add_undefined_methods(name, info)
      info.external.each do |mth|
        if (selected = selected_method(mth, name))
          info.add_dependency(@methods[selected])
        elsif !known_constant?(mth, name)
          @undefined_methods << mth
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
  end
end
