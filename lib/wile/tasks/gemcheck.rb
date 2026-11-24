# frozen_string_literal: true

# wile: os `gem,rbenv`

# ## wile gemcheck ##
# Checks for missing gems in the current Ruby version that are found installed
# in other versions on the system using `rbenv`.
# Usage:
#   wile gemcheck [--all] # checks for missing gems
module Wile
  # This file is loaded upon a :gemcheck task request.
  class Tasks
    GEMCHECK_USAGE = [
      'gemcheck: Takes no arguments with optional all flag.',
      0,
      Set['all']
    ].freeze

    # :reek:UtilityFunction
    def gemcheck(options)
      Usage.new(options, *GEMCHECK_USAGE)
      GemChecker.new(options).run
    end
  end

  # Compares installed gems across rbenv Ruby versions and installs missing.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::GemChecker
    def self.rbenv_versions_prefix
      prefix = File.join(Utilities.rbenv_root, 'versions')
      gemcmd = `rbenv which gem 2>/dev/null`.strip
      raise "Unexpected gem command: #{gemcmd}" unless
        File.directory?(prefix) && gemcmd.start_with?(prefix)

      prefix
    end

    def initialize(options)
      @options = options
      @prefix = self.class.rbenv_versions_prefix
    end

    def self.gem_majors(str)
      return unless str&.start_with?('(') && str.end_with?(')')

      str[1..-2].split(',').filter_map do |item|
        ver = item.sub('default:', '').strip.split.first
        Gem::Version.new(ver).segments.first if Gem::Version.correct?(ver)
      end.uniq.sort
    end

    def self.pair_majors(name, majors, current)
      (majors - current.fetch(name, [])).map { [name, it] }
    end

    def self.missing_gems(gems, current)
      gems.flat_map { |name, majors| pair_majors(name, majors, current) }
    end

    def self.record_missing(missing, version, items)
      items.each { |key| missing[key] << version }
    end

    def self.missing(inventory)
      current = inventory.fetch(RUBY_VERSION, {})
      res = Hash.new { |hash, key| hash[key] = [] }
      inventory.except(RUBY_VERSION).each_with_object(res) do |(ver, gems), out|
        record_missing(out, ver, missing_gems(gems, current))
      end
    end

    def self.collect_gems(gemcmd)
      `#{gemcmd} list`.lines(chomp: true).each_with_object({}) do |line, gems|
        name, vers = line.split(' ', 2)
        majors = gem_majors(vers)
        gems[name] = majors if majors
      end
    end

    def self.report(missing, searched)
      puts "Current Ruby version: #{RUBY_VERSION}".gray
      puts "Searching versions:   #{searched.join(', ')}".gray
      puts 'Gems missing in current found in other versions:'.blue
      missing.sort.each do |(name, major), versions|
        puts "  #{name} (~> #{major}):  #{versions.join(', ')}"
      end
    end

    def self.install_gem(name, major)
      req = "~> #{major}"
      return if Utilities.gem_installed?(name, version: req)

      Utilities.run('gem', 'install', name, '-v', req) do |code, msg|
        raise "#{Sysexits.label(code)}: #{msg}"
      end
    end

    def run
      inventory = build_inventory
      missing = self.class.missing(inventory)
      return puts 'OK'.green if missing.empty?

      prompt_and_install(missing, inventory.keys - [RUBY_VERSION])
    end

    def self.previous_version(versions, current = RUBY_VERSION)
      cur = Gem::Version.new(current)
      older = versions.select do |ver|
        Gem::Version.correct?(ver) && Gem::Version.new(ver) < cur
      end
      older.max_by { Gem::Version.new(it) }
    end

    private

    def prompt_and_install(missing, searched, kls = self.class)
      kls.report(missing, searched)
      Utilities.confirm?('Would you like to install them all?') ||
        raise('Aborted.')
      missing.each_key { |name, major| kls.install_gem(name, major) }
      puts 'OK'.green
    end

    def build_inventory
      target_versions.each_with_object({}) do |ver, inventory|
        gemcmd = File.join(@prefix, ver, 'bin/gem')
        if File.executable?(gemcmd)
          inventory[ver] = self.class.collect_gems(gemcmd)
        end
      end
    end

    def target_versions
      versions = `rbenv versions --bare --skip-aliases`.lines(chomp: true)
      return (versions + [RUBY_VERSION]).uniq if @options.all?

      prev = self.class.previous_version(versions)
      [RUBY_VERSION, prev].compact.uniq
    end
  end
  Tasks.private_constant :GemChecker
end
