# frozen_string_literal: true

# ## wile example ##
# Demonstrates how to create custom project tasks in .tasks/.
# Custom tasks dynamically extend Wile by reopening Wile::Tasks.
#
# Options:
#   --detailed         Display options metadata
#   --limit=INTEGER    Repeat message INTEGER times
#   --reverse          Reverse the greeting text
# Usage:
#   wile example [<name>] [--detailed] [--limit=N] [--reverse] # demo task
module Wile
  # Reopen Wile::Tasks to define the custom task method.
  # The method name must match the file basename (example.rb -> :example).
  class Tasks
    # Define argument and option constraints for Wile::Usage.
    # Format: [error_prefix, validator, ..., Set[allowed_options]]
    #
    # Validators can be:
    #   * Range (e.g. 0..1) or Integer (exact argument count)
    #   * Regexp (matches positional arguments)
    #   * Set (whitelists allowed options from bin/wile reserved list)
    EXAMPLE_USAGE = [
      'example: Accepts at most one name, and flags: detailed, limit, reverse.',
      (0..1),
      Set['detailed', 'limit', 'reverse']
    ].freeze

    # Entry point called by Wile when running: wile example
    # Receives a HelpParser options object with .args and flag accessors.
    # :reek:FeatureEnvy :reek:TooManyStatements
    def example(options)
      args = Usage.new(options, *EXAMPLE_USAGE).args
      name = args&.first || 'World'
      limit = options.limit || 1
      greeting = "Hello, #{name}!"
      greeting = greeting.reverse if options.reverse?

      limit.times { puts greeting.green }
      print_details(name, limit, options) if options.detailed?
    end

    private

    # Helper methods in Tasks that do not reference instance variables
    # use :reek:UtilityFunction to satisfy Reek quality gates.
    # :reek:UtilityFunction
    def print_details(name, limit, options)
      puts "\nDetails:".blue
      puts "  Target:  #{name}"
      puts "  Limit:   #{limit}"
      puts "  Reverse: #{options.reverse?}"
    end
  end
end
