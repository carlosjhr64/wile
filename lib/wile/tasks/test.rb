# frozen_string_literal: true

# ## wile test ##
# Options:
#   --list       Lists tests that will run
#   --quiet      Fault-only
# Usage:
#   wile test [<filematch> [<methodmatch>]] [--list|--quiet] # runs tests
module Wile
  # This file is loaded upon a :test task request.
  class Tasks
    TEST_USAGE = [
      'test: Takes at most two arguments with optional list/quiet flags.',
      (..2), Set['list', 'quiet']
    ].freeze

    # :reek:DuplicateMethodCall Time.now are different times!
    # :reek:FeatureEnvy
    # :reek:TooManyStatements
    def test(options)
      Utilities.verify_project_root!
      filematch, methodmatch = Usage.new(options, *TEST_USAGE).args
      started = Time.now
      Test.test!(filematch, methodmatch,
                 list: options.list?, quiet: options.quiet?)
      return if options.list?

      puts "Time: #{Time.now - started} seconds"
      puts 'OK'.green
    end
  end
end
