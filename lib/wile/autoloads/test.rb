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
        raise "failed: #{tf}" unless system("#{tf} --verbose=important-only")
      end
    end
  end
end
