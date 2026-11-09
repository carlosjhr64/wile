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
      Utilities.verify_project_root!
      match = Usage.new(options, *NVIM_USAGE).args
      files = filter_nvim_files(match)
      return puts files if options.list?

      launch_nvim(files, match)
    end

    private

    def filter_nvim_files(match)
      files = NvimFiles.new.nvim_files
      return files unless match

      files.select { |fn| match.any? { fn.match?(it) } }
    end

    def launch_nvim(files, match)
      if files.empty?
        raise "No files matched: #{match.join(', ')}" if match

        raise 'No files found.'
      end

      exec('nvim', *files)
    end
  end
end
