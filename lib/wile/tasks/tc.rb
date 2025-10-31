# frozen_string_literal: true

# ## wile tc ###
# Usage:
#   wile tc # lists custom unit tests in project
module Wile
  # This file is loaded upon a :tc task request.
  class Tasks
    using Refinement

    TC_USAGE = ['tc: Takes no arguments.', 0, Set[]].freeze

    # rubocop: disable Metrics
    def tc(options)
      Usage.new(options, *TC_USAGE)
      cached = Cache.new.p2c_hash.keys.grep(%r{^test/tc_})
      custom = Dir.glob('test/tc_*').reject { cached.include? it }
      if custom.empty?
        warn 'No custom test/tc_*'.red
      else
        ordered = NvimFiles.new.nvim_files.grep(%r{^lib/})
        ordered.map! { it.split('/')[1..] }
        ordered.map! do |a|
          s = (a.length == 1 ? a[0] : a[1..].join('_')).chomp('.rb')
          "test/tc_#{s}"
        end
        ordered.select! { custom.include? it }
        puts ordered
        puts (ordered - custom).sort
      end
    end
    # rubocop: enable Metrics
  end
end
