# frozen_string_literal: true

# ## wile compare ###
# Usage:
#   wile compare [<match>+] # compares project with template
module Wile
  # This file is loaded upon a :compare task request.
  # :reek:MissingSafeMethod
  class Tasks
    using Refinement

    COMPARE_USAGE = ['compare: Takes one or more file matcher.', Set[]].freeze

    # :reek:NilCheck :reek:TooManyStatements
    def compare(options)
      match = Usage.new(options, *COMPARE_USAGE).args
      p2c, missing = p2c_and_missing
      code = missing.empty? ? 0 : 1
      display_missing(missing, '# Missing:'.red) unless code.zero?
      check_p2c!(p2c, match)
      show = !match.nil?
      display_p2c(p2c, '# Found:'.blue, code:, show:)
    end

    private

    # Files expected to be customized by the user (shown in blue when modified).
    # Other modified files are shown in red as candidates to keep updated with
    # the Wile template. Discrepancies are informational, not errors; it is up
    # to the user to decide what to update, so the exit status remains zero.
    EXPECTED_CHANGES = [
      /README.md/,
      /^(\.ruby-version|\.version|\.irbrc|\.config\.fish)/,
      %r{^(lib/|bin/|\.bin/|\.git/)},
      /^(Gemfile|TODO\.md|CREDITS\.md|History\.txt)/,
      /^(\.gemignore|\.gitignore|\.wileignore)/,
      /^(\.dictionary|\.lexicon)/,
      /^(\.rubocop.*\.yml|\.reek.*\.yml|cucumber\.yml)/
    ].freeze
    private_constant :EXPECTED_CHANGES

    def display_missing(missing, heading)
      puts heading
      missing.display
      puts
    end

    # :reek:FeatureEnvy
    def p2c_and_missing
      p2c, pfiles = Cache.new.as { [it.p2c_hash, it.pfiles] }
      found = (keys = p2c.keys) & pfiles
      missing = keys - found
      [p2c.slice(*found), missing]
    end

    # :reek:DuplicateMethodCall p2c.empty? b/c of p2c.delete_if
    # :reek:UncommunicativeVariableName p
    def check_p2c!(p2c, match)
      raise 'No files found.' if p2c.empty?

      p2c.delete_if { |p, _| match.none? { p.match? it } } if match
      raise "No match: #{match.join(', ')}" if p2c.empty?
    end

    # :reek:LongParameterList :reek:BooleanParameter :reek:TooManyStatements
    # :reek:UncommunicativeVariableName c
    def display_p2c(p2c, heading, cache: Info.info.cache, code: 0, show: false)
      puts heading
      p2c.each do |pf, cf|
        cf = File.join(cache, cf)
        diff = diff(cf, pf, show)
        c = colorized_puts(pf) and code = c
        puts "    |#{diff.lines.join('    |')}" unless diff.empty?
      end
      code
    end

    def colorized_puts(pfile)
      if $CHILD_STATUS.exitstatus.zero?
        puts pfile.green
      elsif EXPECTED_CHANGES.any? { it.match?(pfile) }
        puts pfile.blue
      else
        puts pfile.red
        1
      end
    end

    # :reek:ControlParameter
    def diff(cfile, pfile, show)
      cmp, out = show ? ['colordiff', ''] : ['diff -sq', '>/dev/null']
      if /\.erb$/.match?(cfile) then diff_erb(cfile, pfile, cmp, out)
      else
        cf = Shellwords.escape(cfile)
        pf = Shellwords.escape(pfile)
        `#{cmp} #{cf} #{pf} #{out}`
      end
    end

    # :reek:LongParameterList and :reek:UtilityFunction
    def diff_erb(cfile, pfile, cmp, out)
      result = Info.info.erb_result(cfile)
      IO.popen("#{cmp} - #{pfile} #{out}", 'w+') do |pipe|
        pipe.puts result
        pipe.close_write
        pipe.read
      end
    end
  end
end
