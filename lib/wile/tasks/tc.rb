# frozen_string_literal: true

# ## wile tc ##
# Lists custom unit tests in project, or wile template gates.
# Options:
#   --raw # suppress headers and spaces
# Usage:
#   wile tc [<scope>] [<match>+] [--raw] # lists unit tests
module Wile
  # This file is loaded upon a :tc task request.
  class Tasks
    using Refinement

    TC_USAGE = [
      'tc: Optionally takes scope (project, wile, all), matchers, and --raw.',
      Set['raw']
    ].freeze

    # :reek:TooManyStatements
    # rubocop:disable-next Metrics/MethodLength
    def tc(options)
      Utilities.verify_project_root!
      args = Usage.new(options, *TC_USAGE).args || []
      scopes = %w[project wile all]
      scope = scopes.include?(args.first) ? args.shift.to_sym : :project
      project, wile = tc_test_groups(args)
      case scope
      when :project then display_tc_group(project, 'custom', args)
      when :wile    then display_tc_group(wile, 'Wile template', args)
      when :all
        if options.raw? then display_tc_raw(project, wile, args)
        else display_tc_all(project, wile, args)
        end
      end
    end

    private

    # :reek:DuplicateMethodCall :reek:TooManyStatements
    def tc_test_groups(match)
      p2c = Cache.new.p2c_hash
      cached = p2c.keys.grep(%r{^test/tc_})
      existing = Dir.glob('test/tc_*')
      wile = (cached & existing).sort
      custom = existing - cached
      project = order_tc_custom(custom)
      [filter_tc_matching(project, match), filter_tc_matching(wile, match)]
    end

    # :reek:FeatureEnvy
    def filter_tc_matching(tests, match)
      return tests if match.empty?

      tests.select { |test| match.any? { test.match? it } }
    end

    # :reek:TooManyStatements
    def order_tc_custom(custom)
      nvim_files = NvimFiles.new.nvim_files
      files = nvim_files.grep(%r{^lib/})
      ordered = files.map { lib_to_tc(it) }
      ordered.select! { custom.include? it }
      ordered + (custom - ordered).sort
    end

    # :reek:UtilityFunction
    def lib_to_tc(path)
      seg = path.split('/')[1..]
      name = (seg.length == 1 ? seg[0] : seg[1..].join('_')).chomp('.rb')
      "test/tc_ut_#{name}"
    end

    def display_tc_group(tests, label, match)
      if tests.empty?
        display_tc_none("#{label} test/tc_*", match)
      else
        puts tests
      end
    end

    def display_tc_raw(project, wile, match)
      if project.empty? && wile.empty?
        display_tc_none('test/tc_*', match)
      else
        puts project, wile
      end
    end

    def display_tc_all(project, wile, match)
      if project.empty? && wile.empty?
        display_tc_none('test/tc_*', match)
        return
      end

      show_tc_section('# Project:'.blue, project)
      puts if project.any? && wile.any?
      show_tc_section('# Wile:'.blue, wile)
    end

    def show_tc_section(heading, tests)
      puts heading, tests if tests.any?
    end

    # :reek:FeatureEnvy
    def display_tc_none(label, match)
      msg = if match.empty? then "No #{label}"
            else "No tests matched: #{match.join(', ')}"
            end
      warn msg.red
    end
  end
end
