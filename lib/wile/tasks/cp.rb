# frozen_string_literal: true

# ## wile cp ##
# The force option will overwrite existing files.
# Usage:
#   wile cp [<match>] [-f|--force|-t|--trace] # copy template files into project
module Wile
  # This file is loaded upon a :cp task request.
  class Tasks
    CP_USAGE = ['cp: Takes optionally one argument', (0..1),
                Set['force', 'trace']].freeze

    # :reek:FeatureEnvy :reek:TooManyStatements
    def cp(options)
      match = Usage.new(options, *CP_USAGE).args&.first
      cache = Cache.new(trace: options.trace?)
      p2c = cache.p2c_hash
      p2c = p2c.select { |pfile, _| pfile.match? match } if match
      raise 'no matches found' if p2c.empty?

      force = options.force?
      p2c.each { |pfile, cfile| cache.copy2project(cfile, pfile, force:) }
    end
  end
end
