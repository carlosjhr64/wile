# frozen_string_literal: true

# wile: os `diff`

# ## wile compare ##
# Compares project files with template.
# Usage:
#   wile compare [<match>+] # compares project with template
module Wile
  # This file is loaded upon a :compare task request.
  class Tasks
    COMPARE_USAGE = [
      'compare: Optionally takes one or more file matchers.', Set[]
    ].freeze

    def compare(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      match = Usage.new(options, *COMPARE_USAGE).args
      Comparer.new(match).run
    end
  end

  # Compares project files against the Wile template cache.
  class Comparer
    using WileRefinements
    using UtilitiesRefinements

    # Files expected to be customized by the user (shown in blue when modified).
    # Other modified files are shown in red as candidates to keep updated with
    # the Wile template. Discrepancies are informational, not errors; it is up
    # to the user to decide what to update, so the exit status remains zero.
    EXPECTED_CHANGES = [
      /README\.md/,
      /^(\.ruby-version|\.version|\.irbrc|\.config\.fish)/,
      %r{^(lib/|bin/|\.bin/|\.git/|man/|\.tasks/)},
      /^(Gemfile|TODO\.md|CREDITS\.md|History\.txt)/,
      /^(\.gemignore|\.gitignore|\.wileignore)/,
      /^(\.dictionary|\.lexicon)/,
      /^(\.rubocop.*\.yml|\.reek.*\.yml|cucumber\.yml)/
    ].freeze
    private_constant :EXPECTED_CHANGES

    def initialize(match = nil, info = Info.info)
      @match = match
      @info = info
      @opt, @out = diff_flags
    end

    def self.missing_files(keys, found)
      (keys - found).reject { it.start_with?('.tasks/') }
    end

    def run
      p2c, missing = p2c_and_missing
      p2c.keys.weird_filename!
      display_missing(missing) unless missing.empty?
      display_found(filter_p2c(p2c))
    end

    private

    def p2c_and_missing
      p2c, pfiles = Cache.new.as { [it.p2c_hash, it.pfiles] }
      found = (keys = p2c.keys) & pfiles
      [p2c.slice(*found), Comparer.missing_files(keys, found)]
    end

    def diff_flags
      return ['-sq', '>/dev/null'] unless @match

      color = String.disable_colorization ? '' : '--color=always'
      [color, '']
    end

    def display_missing(missing)
      puts '# Missing:'.red
      missing.display
      puts
    end

    def filter_p2c(p2c)
      raise 'No files found.' if p2c.empty?

      @match ? select_matches(p2c) : p2c
    end

    def display_found(p2c)
      puts '# Found:'.blue
      p2c.each { |pfile, cfile| display_entry(pfile, cfile) }
    end

    def match?(pfile)
      @match.any? { pfile.match?(it) }
    end

    def select_matches(p2c)
      matched = p2c.select { |pfile, _| match?(pfile) }
      raise "No match: #{@match.join(', ')}" if matched.empty?

      matched
    end

    def display_entry(pfile, cfile)
      output = diff(File.join(@info.cache, cfile), pfile)
      colorized_puts(pfile)
      puts "    |#{output.lines.join('    |')}" unless output.empty?
    end

    def colorized_puts(pfile)
      if $CHILD_STATUS.exitstatus.zero?
        puts "✓  #{pfile}".green # UTF-8
      elsif EXPECTED_CHANGES.any? { it.match?(pfile) }
        puts "Δ  #{pfile}".blue # UTF-8
      else
        puts "✗  #{pfile}".red # UTF-8
      end
    end

    def diff(cfile, pfile)
      return diff_erb(cfile, pfile) if cfile.end_with?('.erb')

      `diff #{@opt} #{cfile.sw} #{pfile.sw} #{@out}`
    end

    def diff_erb(erb_file, pfile)
      result = @info.erb_result(erb_file)
      IO.popen("diff #{@opt} - #{pfile.sw} #{@out}", 'w+') do |pipe|
        pipe.puts result
        pipe.close_write
        pipe.read
      end
    end
  end
end
