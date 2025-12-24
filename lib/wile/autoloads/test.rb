# frozen_string_literal: true

# Wile namespace.
module Wile
  # Test module provides methods to run tests.
  module Test
    # :reek:ControlParameter :reek:TooManyStatements
    def self.test!(match = nil)
      Find.find('test') do |tf|
        next unless %r{/tc_\w+$}.match?(tf)
        next if match&.none? { tf.match? it }

        print "#{tf}: ".blue
        options = '--verbose=important-only --ignore-name=test_rubocop_and_reek'
        raise "failed: #{tf}" unless system("#{tf} #{options}")
      end
    end
  end
end
