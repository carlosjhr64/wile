# frozen_string_literal: true

# ## wile install ##
# Builds and installs current project locally,
# uninstalling the version first if already installed.
# Refuses to build unless git status is clean, unless forced.
# Usage:
#   wile install [--force] # install current local project
module Wile
  # This file is loaded upon a :install task request.
  class Tasks
    INSTALL_USAGE = ['install: Takes no arguments with optional force flag.',
                     0, Set['force']].freeze

    # :reek:UtilityFunction
    def install(options, gmu = GemUtils.new, git = Git)
      Utilities.verify_project_root!
      Usage.new(options, *INSTALL_USAGE)
      verify_install(gmu, git) unless options.force?
      reinstall(gmu)
    end

    private

    # :reek:UtilityFunction
    def verify_install(gmu, git)
      git.clean!
      gmu.clean!
      gmu.ready!
    end

    # :reek:UtilityFunction
    def reinstall(gmu)
      gmu.build!
      gmu.uninstall if gmu.installed?
      gmu.install && gmu.rm_pkg
    end
  end
end
