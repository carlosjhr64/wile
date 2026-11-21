# frozen_string_literal: true

# ## wile test ##
# Options:
#   --batch      Run in non-interactive batch mode
#   --list       Lists tests that will run
#   --quiet      Fault-only
# Usage:
#   wile test [<filematch> [<methodmatch>]] [--batch|--list|--quiet] # tc tests
module Wile
  # This file is loaded upon a :test task request.
  class Tasks
    TEST_USAGE = [
      'test: Takes at most two arguments with optional batch/list/quiet flags.',
      (..2), Set['batch', 'list', 'quiet']
    ].freeze

    def test(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      args = Usage.new(options, *TEST_USAGE).args
      TestRunner.new(options, *args).run
    end
  end

  # Runs project test suites and reports elapsed time.
  class TestRunner
    def initialize(options, filematch = nil, methodmatch = nil)
      @options = options
      @filematch = filematch
      @methodmatch = methodmatch
    end

    def run
      started = Time.now
      execute
      report(started) unless @options.list?
    end

    private

    def report(started)
      puts "Time: #{Time.now - started} seconds"
      puts 'OK'.green
    end

    def execute
      Test.test!(@filematch, @methodmatch,
                 batch: @options.batch?,
                 list: @options.list?,
                 quiet: @options.quiet?)
    end
  end
end
