# frozen_string_literal: true

# Namespace: Wile
module Wile
  # Categorizes methods
  class Methods
    using WileRefinements

    attr_reader :implicit_methods, :known_constants, :methods,
                :undefined_methods

    REF = /\w+Refinements::/
    private_constant :REF

    def initialize(dir = 'lib')
      @methods = {}
      @implicit_methods = Set.new
      @known_constants = Set.new
      @undefined_methods = Set.new
      get_code_data(dir)
      @methods.each { |name, entry| add_undefined_methods(name, entry) }
    end

    def self.skip_duck?(mth)
      mth.start_with?('*') ||
        (!/^[A-Z]/.match?(mth) && mth.common_ruby_method_name?)
    end

    def self.skipped_receiver?(mth) = mth.match?(/\A@?(?:options|it|\w+_)#/)

    private

    def get_code_data(dir)
      prefix = "#{dir.delete_prefix('./').delete_suffix('/')}/"
      files = Git.files.select { it.start_with?(prefix) && it.end_with?('.rb') }
      files.each { process_file(it) }
    end

    def process_file(filename, cdt = CodeData.new(filename))
      @known_constants.merge(cdt.constants)
      cdt.names.each { @methods[it] = MethodEntry.new(cdt, it) }
      cdt.attrs.each { @methods[it] = MethodEntry.new(cdt) }
    end

    def unresolved?(mth, entry)
      !recognized?(mth, entry) && !Methods.skip_duck?(mth) &&
        !Methods.skipped_receiver?(mth)
    end

    def recognized?(mth, entry)
      # Immediately return false for non ducks:
      return false unless /\A[^A-Z#].*#/.match?(mth)

      suffix = "##{mth.split('#').last}"
      @methods.select { |key, val| key.end_with?(suffix) && val != entry }
              .each_value { entry.add_dependency(it) }.any?
    end

    def add_undefined_methods(name, entry)
      entry.external.each do |mth|
        if (selected = selected_method(mth, name))
          entry.add_dependency(@methods[selected])
        elsif implicit_new?(mth)
          @implicit_methods << mth
        elsif !known_constant?(mth, name) && unresolved?(mth, entry)
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

    def find_method(target, name)
      keys = @methods.keys.select { it.end_with?(target) }
      keys.detect { name.start_with?(it.sub(REF, '').delete_suffix(target)) }
    end
  end
end
