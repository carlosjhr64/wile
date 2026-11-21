# frozen_string_literal: true

# ## wile tc ##
# Lists custom unit tests in project, or wile template gates.
# Scopes:
#   * project    Custom project unit tests (default)
#   * wile       Wile template quality gates
#   * all        Both project and Wile tests
# Options:
#   --raw        Suppress headers and spaces
# Usage:
#   wile tc [<scope>] [<match>+] [--raw] # lists unit tests
module Wile
  # This file is loaded upon a :tc task request.
  class Tasks
    TC_USAGE = [
      'tc: Optionally takes scope (project, wile, all), matchers, and --raw.',
      Set['raw']
    ].freeze

    def tc(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      args = Usage.new(options, *TC_USAGE).args || []
      TestLister.new(args, options).display
    end
  end

  # Lists project unit tests and Wile template quality gates.
  class TestLister
    SCOPES = %w[project wile all].freeze

    def initialize(args, options)
      @match = args.dup
      @scope = SCOPES.include?(@match.first) ? @match.shift.to_sym : :project
      @options = options
    end

    def self.lib_to_tc(path)
      seg = path.split('/')[1..]
      seg.delete('autoloads')
      name = (seg.length == 1 ? seg[0] : seg[1..].join('_')).chomp('.rb')
      "test/tc_ut_#{name}"
    end

    def self.ranked_tests
      NvimFiles.new.nvim_files.grep(%r{^lib/}).flat_map do |file|
        tc = lib_to_tc(file)
        [tc, "#{tc}_slow"]
      end
    end

    def self.order_custom(custom)
      ordered = ranked_tests.select { custom.include?(it) }
      ordered + (custom - ordered).sort
    end

    def display
      project, wile = load_groups
      case @scope
      when :project then display_group(project, 'custom')
      when :wile    then display_group(wile, 'Wile template')
      when :all     then display_all(project, wile)
      end
    end

    private

    def load_groups
      cached = Cache.new.p2c_hash.keys.grep(%r{^test/tc_})
      existing = Dir.glob('test/tc_*')
      project = TestLister.order_custom(existing - cached)
      wile = (cached & existing).sort
      [filter_matching(project), filter_matching(wile)]
    end

    def display_group(tests, label)
      return display_none("#{label} test/tc_*") if tests.empty?

      puts tests
    end

    def filter_matching(tests)
      @match.empty? ? tests : tests.select { match?(it) }
    end

    def match?(test)
      @match.any? { test.match?(it) }
    end

    def display_none(label)
      msg = if @match.empty? then "No #{label}"
            else "No tests matched: #{@match.join(', ')}"
            end
      warn msg.red
    end

    def display_all(project, wile)
      return display_none('test/tc_*') if project.empty? && wile.empty?
      return puts(project, wile) if @options.raw?

      show_section('# Project:'.blue, project)
      puts if project.any? && wile.any?
      show_section('# Wile:'.blue, wile)
    end

    def show_section(heading, tests)
      puts heading, tests if tests.any?
    end
  end
end
