# frozen_string_literal: true

# Wile namespace.
module Wile
  # Test module provides methods to run tests.
  module Test
    def self.test_files
      Dir['test/**/tc_*'].select do |tf|
        File.file?(tf) && %r{/tc_\w+$}.match?(tf)
      end.sort
    end
    private_class_method :test_files

    # :reek:ControlParameter
    def self.options(methodmatch, quiet)
      opt = %w[--verbose=important-only --ignore-name=test_rubocop_and_reek]
      opt << '--progress-style=fault-only' if quiet
      opt << "--name=/#{methodmatch}/" if methodmatch
      opt
    end
    private_class_method :options

    # :reek:BooleanParameter :reek:ControlParameter
    # :reek:LongParameterList :reek:TooManyStatements
    def self.test!(filematch = nil, methodmatch = nil,
                   list: false, quiet: false)
      files = test_files
      files.select! { it.match?(filematch) } if filematch
      return puts files if list

      opt = options(methodmatch, quiet)
      files.each do |tf|
        puts "#{tf}: ".blue
        raise "failed: #{tf}" unless system(tf, *opt)
      end
    end
  end
end
