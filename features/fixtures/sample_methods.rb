# frozen_string_literal: true

# :reek:IrresponsibleModule
module SampleMethods
  # :reek:IrresponsibleModule :reek:MissingSafeMethod
  class Worker
    # :reek:UtilityFunction
    def self.build
      new.run
    end

    def initialize
      @active = true
    end

    def run = 10

    # :reek:UtilityFunction
    def [](key)
      key.to_s
    end

    def valid?
      @active
    end

    def reset!
      @active = false
    end

    private

    def secret
      42
    end
  end

  # :reek:IrresponsibleModule
  class Uninitialized
    # :reek:UtilityFunction
    def self.spawn
      new.status
    end

    def status
      :ready
    end
  end
end
