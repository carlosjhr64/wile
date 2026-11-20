# frozen_string_literal: true

# Namespace: Wile
module Wile
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
  #                    "dependency_file1", "dependency_file2",...],
  #
  #     # Files that need "method":
  #     dependants: ["method_file",
  #                  "dependant_file1", "dependant_file2",...],
  #
  #     # Methods not in "method_file", Kernel, nor Standard Library:
  #     external: ["external_method1", "external_method2",...]
  #   }
  MethodEntry = Struct.new(:filename, :dependencies, :dependants,
                           :external) do
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
end
