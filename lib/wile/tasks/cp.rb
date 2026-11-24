# frozen_string_literal: true

# ## wile cp ##
# Copies template files from cache/ into the current project.
# The force option will overwrite existing files; trace prints skipped files.
# Usage:
#   wile cp [<match>] [--force] [--trace] # copy template files into project
module Wile
  # This file is loaded upon a :cp task request.
  class Tasks
    CP_USAGE = [
      'cp: Optionally takes one argument and flags: force, trace.',
      (0..1),
      Set['force', 'trace']
    ].freeze

    def cp(options, cache = nil)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      match = Usage.new(options, *CP_USAGE).args&.first
      cache ||= Cache.new(trace: options.trace?)
      Copier.new(cache, match, options).copy
    end
  end

  # Copies matching template files from cache into the project.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::Copier
    def initialize(cache, match, options)
      @cache = cache
      @match = match
      @options = options
    end

    def copy
      p2c = filtered_p2c
      raise 'no matches found' if p2c.empty?

      force = @options.force?
      p2c.each { |pfile, cfile| @cache.copy2project(cfile, pfile, force:) }
    end

    private

    def filtered_p2c
      p2c = @cache.p2c_hash
      @match ? p2c.select { |pfile, _| pfile.match?(@match) } : p2c
    end
  end
  Tasks.private_constant :Copier
end
