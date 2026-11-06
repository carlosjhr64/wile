# frozen_string_literal: true

# ## wile dictionary ##
# Usage:
#   wile dictionary [--check] [--yes] # view changes and update dictionary
module Wile
  # This file is loaded upon a :dictionary task request.
  class Tasks
    DICTIONARY_USAGE = ['dictionary: Takes no arguments.',
                        0, Set['check', 'yes']].freeze

    def dictionary(options)
      Utilities.verify_project_root!
      Usage.new(options, *DICTIONARY_USAGE)
      return puts 'OK'.green if dictionary_ok?(options)

      puts 'Fail'.red
      exit(EX_FAIL)
    end

    private

    # :reek:TooManyStatements
    def dictionary_ok?(options)
      return true if system 'test/tc_dictionary --verbose=silent'

      diff = String.disable_colorization ? %w[diff] : %w[diff --color]
      system(*diff, '.dictionary', 'tmp/dictionary')
      return false if options.check? # Just checking

      unless options.yes?
        print 'Update dictionary (Yes/No)?: '.yellow
        return false unless $stdin.gets&.match?(/^[Yy]/)
      end

      FileUtils.cp 'tmp/dictionary', '.dictionary'
      true
    end
  end
end
