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
    REF = /\w+Refinements::/
    private_constant :Info, :REF

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

    def find_method(target, name)
      keys = @methods.keys.select { it.end_with?(target) }
      keys.detect { name.start_with?(it.sub(REF, '').delete_suffix(target)) }
    end

    def selected_method(mth, name)
      find_method(mth.sub(/\.new$/, '#initialize'), name) ||
        find_method(mth.sub(/^.*#/, 'Kernel#'), name) ||
        find_method(mth.sub('.', '#'), name)
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

    def known_constant?(mth, name, const = mth.split('.').first)
      return true if @known_constants.include?(const)

      @known_constants.select { it.end_with?("::#{const}") }
                      .any? { name.start_with?(it.delete_suffix("::#{const}")) }
    end
  end
end
