# frozen_string_literal: true

# ## wile update ##
# Will update README's HELP with current --help.
# Will update gemspec.
# You can optionally specify which if not both.
# git status must be clean.
# Usage:
#   wile update [README|gemspec] [-f|--force] # update README and gemspec
module Wile
  # This file is loaded upon a :update task request.
  class Tasks
    UPDATE_USAGE = ['update: May specify either README or gemspec.',
                    (..1), /^(README|gemspec)$/, Set['force']].freeze

    def update(options)
      token, = Usage.new(options, *UPDATE_USAGE).args
      Git.clean! unless options.force?
      do_update(token)
      do_update_report
    end

    private

    def do_update_report(info = Info.info)
      if Git.clean? then puts 'up-to-date'.green
      else
        Git.diff(info.readme, info.gemspec)
        puts 'verify updated changes'.red
      end
    end

    # :reek:ControlParameter and :reek:UtilityFunction
    # :reek:DuplicateMethodCall `#update!` are on different cases!
    def do_update(token)
      case token
      when 'README'
        Readme.new.update!
      when 'gemspec'
        Gemspec.new.update!
      else
        Readme.new.update!
        Gemspec.new.update!
      end
    end
  end
end
