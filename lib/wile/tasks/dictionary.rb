# frozen_string_literal: true

# ## wile dictionary ##
# Usage:
#   wile dictionary [--check] # view changes and update dictionary
module Wile
  # This file is loaded upon a :dictionary task request.
  class Tasks
    DICTIONARY_USAGE = ['dictionary: Takes no arguments.',
                        0, Set['check']].freeze

    def dictionary(options)
      Usage.new(options, *DICTIONARY_USAGE)
      if dictionary_ok?(options)
        puts 'OK'.green
      else
        puts 'Fail'.red
        exit(EX_FAIL)
      end
    end

    private

    # :reek:TooManyStatements
    def dictionary_ok?(options)
      return true if system 'test/tc_dictionary --verbose=silent'

      system 'colordiff .dictionary tmp/dictionary'
      return false if options.check? # Just checking

      print 'Update dictionary(Yes/No)?: '.yellow
      return false unless $stdin.gets&.include?('Y')

      FileUtils.cp 'tmp/dictionary', '.dictionary'
      true
    end
  end
end
