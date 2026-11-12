# frozen_string_literal: true

# Namespace: Wile
module Wile
  # Categorizes methods
  class Smell
    attr_reader :implicit_methods, :known_constants, :methods,
                :undefined_methods

    # Tracks method definition metadata and file dependencies:
    # * filename: path of the file where the method is defined
    # * dependencies: files containing methods this method invokes
    # * dependants: files containing methods that invoke this method
    # * external: outgoing calls unresolved in filename, stdlib, or Kernel
    #
    #   @methods["method"] = {
    #     # File where method is defined:
    #     filename: "method_file",
    #
    #     # Files "method" needs:
    #     dependencies: ["method_file",
    #                    "dependancy_file1", "dependancy_file2",...],
    #
    #     # Files that need "method":
    #     dependants: ["method_file",
    #                  "dependant_file1", "dependant_file2",...],
    #
    #     # Methods not in "method_file", Kernel, nor Standard Library:
    #     external: ["external_method1", "external_method2",...]
    #   }
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
      @implicit_methods = Set.new
      @known_constants = Set.new
      @undefined_methods = Set.new
      get_code_data(dir)
      @methods.each { |name, info| add_undefined_methods(name, info) }
    end

    private

    def get_code_data(dir)
      prefix = "#{dir.delete_prefix('./').delete_suffix('/')}/"
      files = Git.files.select { it.start_with?(prefix) && it.end_with?('.rb') }
      files.each { process_file(it) }
    end

    def process_file(filename)
      cdt = CodeData.new(filename)
      @known_constants.merge(cdt.constants)
      cdt.names.each { @methods[it] = Info.new(cdt, it) }
    end

    def find_method(target, name)
      keys = @methods.keys.select { it.end_with?(target) }
      keys.detect { name.start_with?(it.sub(REF, '').delete_suffix(target)) }
    end

    # Resolves an external call (`mth`) to a defined method in the caller's
    # (`name`) scope by trying three transformations:
    # 1. `.new` to `#initialize` (instantiations)
    # 2. `#method` to `Kernel#method` (Kernel refinements)
    # 3. `.method` to `#method` (module functions or instance calls)
    # Basically looks for the method definition in the file set or in Kernel.
    def selected_method(mth, name)
      find_method(mth.sub(/\.new$/, '#initialize'), name) ||
        find_method(mth.sub(/^.*#/, 'Kernel#'), name) ||
        find_method(mth.sub('.', '#'), name)
    end

    # Checks whether an external call is an invocation of `.new` on a known
    # class in the project that lacks an explicit `initialize` method (using
    # Ruby's implicit default constructor).
    def implicit_new?(mth)
      return false unless mth.end_with?('.new')

      target = mth.delete_suffix('.new')
      # Is this a class defined in our project that has methods?
      @methods.each_key.any? { it.split(/[.#]/).first.end_with?(target) }
    end

    def add_undefined_methods(name, info)
      info.external.each do |mth|
        if (selected = selected_method(mth, name))
          info.add_dependency(@methods[selected])
        elsif implicit_new?(mth)
          @implicit_methods << mth
        elsif !known_constant?(mth, name)
          @undefined_methods << mth
        end
      end
    end

    # Checks whether an external call's receiver constant is known and
    # accessible within the caller's (`name`) lexical namespace scope.
    # Matches exact constant paths or constants sharing the caller's scope.
    def known_constant?(mth, name, const = mth.split('.').first)
      return true if @known_constants.include?(const)

      @known_constants.select { it.end_with?("::#{const}") }
                      .any? { name.start_with?(it.delete_suffix("::#{const}")) }
    end
  end
end
