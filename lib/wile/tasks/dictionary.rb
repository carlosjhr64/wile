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
      DictionaryUpdater.new(options).run
    end
  end

  # Checks and updates the project .dictionary file.
  class DictionaryUpdater
    def initialize(options)
      @options = options
    end

    def run
      return puts 'OK'.green if ok?

      raise 'Fail'
    end

    def self.diff
      opts = String.disable_colorization ? [] : ['--color']
      system('diff', *opts, '.dictionary', 'tmp/.dictionary')
    end

    private

    def ok?
      return true if system 'test/tc_dictionary --verbose=silent'

      DictionaryUpdater.diff
      return false unless update?

      FileUtils.cp 'tmp/.dictionary', '.dictionary'
      true
    end

    def update?
      !@options.check? &&
        (@options.yes? || Utilities.confirm?('Update dictionary?'))
    end
  end
end
