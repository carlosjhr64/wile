# frozen_string_literal: true

# ## wile nvim ##
# nvim with the standard(matching) files:
# README.md, bin/*, lib/**.rb
# Usage:
#   wile nvim [<match>+] [--list] # spawn nvim with(matching) files
module Wile
  # This file is loaded upon a :nvim task request.
  class Tasks
    NVIM_USAGE = ['nvim: Optionally takes one or more arguments.',
                  Set['list']].freeze

    # :reek:TooManyStatements
    def nvim(options)
      match = Usage.new(options, *NVIM_USAGE).args
      files = NvimFiles.new.nvim_files
      files.select! { |fn| match.any? { fn.match? it } } if match
      if options.list?
        puts files
      else
        exec('nvim', *files)
      end
    end
  end
end
