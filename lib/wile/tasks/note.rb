# frozen_string_literal: true

# ## wile note ##
# Puts each NOTE line.
# Usage:
#   wile note [<match>+] # scrape ruby files for note's
module Wile
  # This file is loaded upon a :note task request.
  class Tasks
    NOTE_USAGE = ['note: Optionally takes one or more arguments.', Set[]].freeze

    # :reek:TooManyStatements
    def note(options)
      match = Usage.new(options, *NOTE_USAGE).args
      Project.rbfiles.each do |fn|
        next if match&.none? { fn.match? it }

        string = `egrep '#\s*NOTE' #{Shellwords.escape(fn)}`
        next if string.empty?

        puts fn.blue
        puts string
      end
    end
  end
end
