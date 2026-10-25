# frozen_string_literal: true

# ## wile lexicon ##
# Usage:
#   wile lexicon [--check] # view changes and update lexicon
module Wile
  # This file is loaded upon a :lexicon task request.
  class Tasks
    LEXICON_USAGE = ['lexicon: Takes no arguments.', 0, Set['check']].freeze

    def lexicon(options)
      Usage.new(options, *LEXICON_USAGE)
      if lexicon_ok?(options)
        puts 'OK'.green
      else
        puts 'Fail'.red
        exit(EX_FAIL)
      end
    end

    private

    # :reek:TooManyStatements
    def lexicon_ok?(options)
      return true if system 'test/tc_lexicon --verbose=silent'

      system 'colordiff .lexicon tmp/lexicon'
      return false if options.check?

      print 'Update lexicon(Yes/No)?: '
      return false unless $stdin.gets&.include?('Y')

      FileUtils.cp 'tmp/lexicon', '.lexicon'
      true
    end
  end
end
