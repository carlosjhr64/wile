# frozen_string_literal: true

# :reek:UncommunicativeModuleName
module A
  # :reek:IrresponsibleModule :reek:UncommunicativeModuleName
  class B
    C = ->(arg) { arg + 1 }

    def self.mth
      new.mth
    end

    # :reek:UtilityFunction
    def initialize
      C.call(1)
    end

    def mth = 5

    def mth!(arg)
      mth?(arg) ? 4 : 6
    end

    # :reek:UncommunicativeParameterName :reek:UnusedParameters
    def mth?(arg, arg2 = nil, arg3: 5)
      # 1. This is a comment
      # 2. This is a comment
    end
  end
end

# :reek:UncommunicativeModuleName
module X
  # :reek:IrresponsibleModule :reek:UncommunicativeModuleName
  class Y
    Q = 'q'

    def self.abc
      Q.upcase
    end
  end

  R = [].freeze

  # :reek:IrresponsibleModule :reek:UncommunicativeModuleName
  class Z
    # :reek:UtilityFunction
    def abc
      R.sort
    end
  end
end

# :reek:IrresponsibleModule
module OK
  def self.ok?
    true
  end
end

OK.ok?
