# frozen_string_literal: true

module A
  class B
    C = ->(arg) { arg + 1 }

    def self.mth
      new.mth
    end

    def initialize
      C.call(1)
    end

    def mth = 5

    def mth!(arg)
      mth?(arg) ? 4 : 6
    end

    def mth?(arg, arg2 = nil, arg3: 5)
      # 1. This is a comment
      # 2. This is a comment
    end
  end
end

module X
  class Y
    Q = 'q'

    def self.abc
      Q.upcase
    end
  end

  R = [].freeze

  class Z
    def abc
      R.sort
    end
  end
end

module OK
  def self.ok?
    true
  end
end

OK.ok?
