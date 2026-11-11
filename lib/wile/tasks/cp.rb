# frozen_string_literal: true

# ## wile cp ##
# The force option will overwrite existing files.
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

    # :reek:FeatureEnvy :reek:TooManyStatements
    def cp(options, cache = nil)
      Utilities.verify_project_root!
      match = Usage.new(options, *CP_USAGE).args&.first
      cache ||= Cache.new(trace: options.trace?)
      p2c = filter_p2c(cache.p2c_hash, match)
      raise 'no matches found' if p2c.empty?

      force = options.force?
      p2c.each { |pfile, cfile| cache.copy2project(cfile, pfile, force:) }
    end

    private

    # :reek:UtilityFunction
    def filter_p2c(p2c, match)
      match ? p2c.select { |pfile, _| pfile.match?(match) } : p2c
    end
  end
end
