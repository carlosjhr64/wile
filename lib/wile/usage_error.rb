# frozen_string_literal: true

# Wile namespace.
module Wile
  # UsageError is raised when the usage of a task is incorrect.
  # It provides a message that includes the help information for the task.
  class UsageError < RuntimeError
    def initialize(msg = $ERROR_INFO&.message)
      if msg
        key, message = msg.split(':', 2).map(&:strip)
        if message && (help = Help[key.to_sym])
          msg = help + message
        end
      end
      super
    end
  end
end
