# frozen_string_literal: true

# ## wile install ##
# Installs current version of project,
# uninstalling the version if it exists.
# Usage:
#   wile install [-f|--force] # install current local project
module Wile
  # This file is loaded upon a :install task request.
  class Tasks
    INSTALL_USAGE = ['install: Takes no arguments with optional force flag.',
                     0, Set['force']].freeze

    # :reek:UtilityFunction :reek:TooManyStatements
    def install(options)
      Usage.new(options, *INSTALL_USAGE)
      gmu = GemUtils.new
      Git.clean! && gmu.clean! unless options.force?
      gmu.ready!
      gmu.build!

      gmu.uninstall if gmu.installed?
      gmu.install && gmu.rm_pkg
    end
  end
end
