# frozen_string_literal: true

# ## wile mkdir ###
# Usage:
#   wile mkdir <dirname> # creates project dirname
module Wile
  # This file is loaded upon a :mkdir task request.
  class Tasks
    MKDIR_USAGE = ['mkdir: Takes one argument.', 1, /^\w+$/, Set[]].freeze

    def mkdir(options)
      # setting dirname as a side effect
      dirname, = Usage.new(options, *MKDIR_USAGE).args
      raise "#{dirname} exists!" if File.exist? dirname

      info = Info.new(dirname:)
      Cache.new(info).make
    end
  end
end
