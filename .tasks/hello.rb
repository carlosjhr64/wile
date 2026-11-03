# frozen_string_literal: true

# ## wile hello ##
# Usage:
#   wile hello # prints Hello World
module Wile
  # This file is loaded upon a :hello task request.
  class Tasks
    def hello(_options)
      puts 'Hello World'
    end
  end
end
