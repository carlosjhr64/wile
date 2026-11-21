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
#   wile update [README|gemspec|man] [--force] # update project files
module Wile
  # This file is loaded upon a :update task request.
  class Tasks
    UPDATE_USAGE = ['update: May specify README, gemspec, or man.',
                    (..1), /^(README|gemspec|man)$/, Set['force']].freeze

    def update(options, info = Info.info)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      target, = Usage.new(options, *UPDATE_USAGE).args
      Git.clean! unless options.force?
      Updater.new(info, target).update
    end
  end

  # Updates README, gemspec, and manpage files and reports git diffs.
  class Updater
    UPDATERS = {
      'README' => Readme,
      'gemspec' => Gemspec,
      'man' => Manpage
    }.freeze

    def initialize(info = Info.info, target = nil)
      @info = info
      @target = target
    end

    def update
      targets = Array(UPDATERS.fetch(@target) { UPDATERS.values })
      targets.each { it.new(@info).update! }
      report
    end

    private

    def report
      return puts 'up-to-date'.green if Git.clean?

      Git.diff(*diff_targets)
      puts 'verify updated changes'.red
    end

    def diff_targets
      paths = [@info.readme, @info.gemspec]
      paths << 'man' if File.directory?('man')
      paths
    end
  end
end
