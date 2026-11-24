# frozen_string_literal: true

# ## wile nvim ##
# Opens project standard files in Neovim.
# Options:
#   --list # list files instead of launching Neovim
# Usage:
#   wile nvim [<match>+] [--list] # spawn nvim with(matching) files
module Wile
  # This file is loaded upon a :nvim task request.
  class Tasks
    NVIM_USAGE = ['nvim: Optionally takes one or more arguments ' \
                  'with optional list flag.',
                  Set['list']].freeze

    def nvim(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      match = Usage.new(options, *NVIM_USAGE).args
      NvimLauncher.new(match, options).run
    end
  end

  # Lists or opens matching project files in Neovim.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::NvimLauncher
    def initialize(match, options)
      @match = match
      @options = options
    end

    def run
      files = selected_files
      return puts files if @options.list?

      launch(files)
    end

    private

    def selected_files
      files = NvimFiles.new.nvim_files
      return files unless @match

      files.grep(Regexp.union(@match.map { Regexp.new(it) }))
    end

    def launch(files)
      if files.empty?
        raise "No files matched: #{@match.join(', ')}" if @match

        raise 'No files found.'
      end

      exec('nvim', *files)
    end
  end
  Tasks.private_constant :NvimLauncher
end
