# frozen_string_literal: true

# ## wile build ##
# Builds the gem pkg.
# Will refuse(unless forced) if git status is not clean.
# Usage:
#   wile build [--force] # build gem pkg
module Wile
  # This file is loaded upon a :build task request.
  class Tasks
    BUILD_USAGE = ['build: Takes no arguments with optional force flag.',
                   0, Set['force']].freeze

    def build(options, gmu = GemUtils.new, git = Git)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *BUILD_USAGE)
      Builder.new(options, gmu, git).build
    end
  end

  # Verifies project state and builds the gem package.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::Builder
    def initialize(options, gmu = GemUtils.new, git = Git)
      @options = options
      @gmu = gmu
      @git = git
    end

    def build
      verify unless @options.force?
      @gmu.build!
    end

    private

    def verify
      @git.clean!
      @gmu.clean!
      @gmu.ready!
    end
  end
  Tasks.private_constant :Builder
end
