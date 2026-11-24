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

    def install(options, gmu = GemUtils.new, git = Git)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *INSTALL_USAGE)
      Installer.new(options, gmu, git).install
    end
  end

  # Builds and installs the current project gem locally.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::Installer
    def initialize(options, gmu = GemUtils.new, git = Git)
      @options = options
      @gmu = gmu
      @git = git
    end

    def install
      verify unless @options.force?
      reinstall
    end

    private

    def verify
      @git.clean!
      @gmu.clean!
      @gmu.ready!
    end

    def reinstall
      @gmu.build!
      @gmu.uninstall! if @gmu.installed?
      @gmu.install! && @gmu.rm_pkg
    end
  end
  Tasks.private_constant :Installer
end
