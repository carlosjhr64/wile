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
      Utilities.verify_project_root!
      Usage.new(options, *LEXICON_USAGE)
      return puts 'OK'.green if lexicon_ok?(options)

      puts 'Fail'.red
      exit(EX_FAIL)
    end

    private

    # :reek:TooManyStatements
    def lexicon_ok?(options)
      return true if system 'test/tc_lexicon --verbose=silent'

      diff = String.disable_colorization ? %w[diff] : %w[diff --color]
      system(*diff, '.lexicon', 'tmp/.lexicon')
      return false if options.check?

      unless options.yes?
        print 'Update lexicon (Yes/No)?: '.yellow
        return false unless $stdin.gets&.match?(/^[Yy]/)
      end

      FileUtils.cp 'tmp/.lexicon', '.lexicon'
      true
    end
  end
end
