# frozen_string_literal: true

# ## wile install ##
# Installs current version of project,
# uninstalling the version if it exists.
# Usage:
#   wile install [--force] # install current local project
module Wile
  # This file is loaded upon a :install task request.
  class Tasks
    INSTALL_USAGE = ['install: Takes no arguments with optional force flag.',
                     0, Set['force']].freeze

    # :reek:UtilityFunction :reek:TooManyStatements
    def install(options)
      Utilities.verify_project_root!
      Usage.new(options, *INSTALL_USAGE)
      gmu = GemUtils.new
      unless options.force?
        Git.clean! && gmu.clean!
        gmu.ready!
      end
      gmu.build!

      gmu.uninstall if gmu.installed?
      gmu.install && gmu.rm_pkg
    end
  end
end
