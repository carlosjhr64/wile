# frozen_string_literal: true

# ## wile test ##
# Usage:
#   wile test [<match>+] # runs tests
module Wile
  # This file is loaded upon a :test task request.
  class Tasks
    TEST_USAGE = ['test: Optionally takes one or more arguments.', Set[]].freeze

    # :reek:DuplicateMethodCall Time.now are different times!
    def test(options)
      match = Usage.new(options, *TEST_USAGE).args
      started = Time.now
      Test.test!(match)
      puts "Time: #{Time.now - started} seconds".blue
      puts 'OK'.green
    end
  end
end
