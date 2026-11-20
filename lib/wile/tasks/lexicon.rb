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
      return puts 'OK'.green if lexicon_ok?(options)

      raise 'Fail'
    end

    private

    # :reek:TooManyStatements
    def lexicon_ok?(options)
      return true if system 'test/tc_lexicon --verbose=silent'

      opts = String.disable_colorization ? [] : ['--color']
      system('diff', *opts, '.lexicon', 'tmp/.lexicon')
      return false if options.check?
      return false unless options.yes? ||
                          Utilities.confirm?('Update lexicon?')

      FileUtils.cp 'tmp/.lexicon', '.lexicon'
      true
    end
  end
end
