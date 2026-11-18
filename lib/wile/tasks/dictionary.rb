# frozen_string_literal: true

# wile: os `diff`

# ## wile dictionary ##
# Usage:
#   wile dictionary [--check] [--yes] # view changes and update dictionary
module Wile
  # This file is loaded upon a :dictionary task request.
  class Tasks
    DICTIONARY_USAGE = ['dictionary: Takes no arguments.',
                        0, Set['check', 'yes']].freeze

    def dictionary(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *DICTIONARY_USAGE)
      return puts 'OK'.green if dictionary_ok?(options)

      raise 'Fail'
    end

    private

    # :reek:TooManyStatements
    def dictionary_ok?(options)
      return true if system 'test/tc_dictionary --verbose=silent'

      diff = String.disable_colorization ? %w[diff] : %w[diff --color]
      system(*diff, '.dictionary', 'tmp/.dictionary')
      return false if options.check? # Just checking
      return false unless options.yes? ||
                          Utilities.confirm?('Update dictionary?')

      FileUtils.cp 'tmp/.dictionary', '.dictionary'
      true
    end
  end
end
