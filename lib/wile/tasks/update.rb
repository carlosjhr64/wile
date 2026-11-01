# frozen_string_literal: true

# ## wile update ##
# Will update README's version, copyright, and active console blocks.
# In ```console blocks, a first line matching:
#   $ <project> [<args>] #>>
# runs ./bin/<project> [<args>] and inserts its output into the block.
# (Only when bin/<project> exists; only run on projects you trust.)
# Will also update gemspec and manpage.
# You can optionally specify which if not all.
# Git status must be clean, unless forced.
# Usage:
#   wile update [README|gemspec|man] [-f|--force] # update project files
module Wile
  # This file is loaded upon a :update task request.
  class Tasks
    UPDATE_USAGE = ['update: May specify either README, gemspec, or man.',
                    (..1), /^(README|gemspec|man)$/, Set['force']].freeze

    UPDATERS = {
      'README' => [Readme],
      'gemspec' => [Gemspec],
      'man' => [Manpage]
    }.freeze

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
        targets = [info.readme, info.gemspec]
        targets << 'man' if File.directory?('man')
        Git.diff(*targets)
        puts 'verify updated changes'.red
      end
    end

    # :reek:ControlParameter and :reek:UtilityFunction
    def do_update(token)
      targets = UPDATERS.fetch(token) { [Readme, Gemspec, Manpage] }
      targets.each { it.new.update! }
    end
  end
end
