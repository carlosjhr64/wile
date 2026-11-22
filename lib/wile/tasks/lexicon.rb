# frozen_string_literal: true

# wile: os `diff`

# ## wile lexicon ##
# Usage:
#   wile lexicon [--check] [--yes] # view changes and update lexicon
module Wile
  # This file is loaded upon a :lexicon task request.
  class Tasks
    LEXICON_USAGE = ['lexicon: Takes no arguments.',
                     0, Set['check', 'yes']].freeze

    def lexicon(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *LEXICON_USAGE)
      LexiconUpdater.new(options).run
    end
  end

  # Checks and updates the project .lexicon file.
  class LexiconUpdater
    def initialize(options)
      @options = options
    end

    def run
      return puts 'OK'.green if ok?

      raise 'Fail'
    end

    def self.diff
      opts = String.disable_colorization ? [] : ['--color']
      system('diff', *opts, '.lexicon', 'tmp/.lexicon')
    end

    private

    def ok?
      return true if system 'test/tc_lexicon --verbose=silent'

      LexiconUpdater.diff
      return false unless update?

      FileUtils.cp 'tmp/.lexicon', '.lexicon'
      true
    end

    def update?
      !@options.check? &&
        (@options.yes? || Utilities.confirm?('Update lexicon?'))
    end
  end
end
