# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
# rubocop:disable Style/OneClassPerFile
# rubocop:disable Style/RedundantConstantBase
# :reek:IrresponsibleModule :reek:MissingSafeMethod :reek:UtilityFunction
def toplevel_work
  :ok
end

# :reek:IrresponsibleModule
module SampleScopes
  # :reek:IrresponsibleModule
  class Base
    def report
      :ready
    end
  end
end

SampleScopes::SCOPED_LIMIT = 50

# :reek:IrresponsibleModule
class SampleScopes::CompactNested
  def perform
    :done
  end
end

# :reek:IrresponsibleModule
class SampleScopes::SingletonService
  class << self
    def activate
      :active
    end
  end
end

# :reek:IrresponsibleModule :reek:UtilityFunction
def SampleScopes.service_helper
  SingletonService.activate
end

# :reek:IrresponsibleModule :reek:UtilityFunction
def toplevel_call
  ::File.exist?('test')
  nil
end
# rubocop:enable Style/ClassAndModuleChildren
# rubocop:enable Style/OneClassPerFile
# rubocop:enable Style/RedundantConstantBase
