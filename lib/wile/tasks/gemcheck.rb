# frozen_string_literal: true

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

    def gemcheck(options)
      Usage.new(options, *GEMCHECK_USAGE)
      gemcheck_do(rbenv_versions_prefix, all: options.all?)
    end

    private

    def rbenv_versions_prefix
      root = `rbenv root 2>/dev/null`.strip
      prefix = File.join(root, 'versions')
      gemcmd = `rbenv which gem 2>/dev/null`.strip
      raise "Unexpected gem command: #{gemcmd}" unless
        File.directory?(prefix) && gemcmd.start_with?(prefix)

      prefix
    end

    # :reek:BooleanParameter
    def gemcheck_inventory(prefix, all: false)
      target_versions(all:).each_with_object({}) do |ver, inventory|
        gemcmd = File.join(prefix, ver, 'bin/gem')
        inventory[ver] = collect_gems(gemcmd) if File.executable?(gemcmd)
      end
    end

    # :reek:BooleanParameter :reek:ControlParameter :reek:UtilityFunction
    def target_versions(all: false)
      versions = `rbenv versions --bare --skip-aliases`.lines(chomp: true)
      return (versions + [RUBY_VERSION]).uniq if all

      prev = previous_version(versions)
      [RUBY_VERSION, prev].compact.uniq
    end

    # :reek:UtilityFunction
    def previous_version(versions, current = RUBY_VERSION)
      cur = Gem::Version.new(current)
      older = versions.select do |ver|
        Gem::Version.correct?(ver) && Gem::Version.new(ver) < cur
      end
      older.max_by { Gem::Version.new(it) }
    end

    # :reek:UtilityFunction
    def collect_gems(gemcmd)
      `#{gemcmd} list`.lines(chomp: true).each_with_object({}) do |line, gems|
        name, vers = line.split(' ', 2)
        majors = gem_majors(vers)
        gems[name] = majors if majors
      end
    end

    # :reek:UtilityFunction
    def gem_majors(str)
      return unless str&.start_with?('(') && str.end_with?(')')

      str[1..-2].split(',').filter_map do |item|
        ver = item.sub('default:', '').strip.split.first
        Gem::Version.new(ver).segments.first if Gem::Version.correct?(ver)
      end.uniq.sort
    end

    def gemcheck_report(missing, searched)
      puts "Current Ruby version: #{RUBY_VERSION}".gray
      puts "Searching versions:   #{searched.join(', ')}".gray
      puts 'Gems missing in current found in other versions:'.blue
      missing.sort.each do |(name, major), versions|
        puts "  #{name} (~> #{major}):  #{versions.join(', ')}"
      end
    end

    # :reek:BooleanParameter
    def gemcheck_do(prefix, all: false)
      inventory = gemcheck_inventory(prefix, all:)
      missing = gemcheck_missing(inventory)
      return puts 'OK'.green if missing.empty?

      prompt_and_install(missing, inventory.keys - [RUBY_VERSION])
    end

    def prompt_and_install(missing, searched)
      gemcheck_report(missing, searched)
      puts 'Would you like to install them all? (Y/n)'.yellow
      exit(EX_NO) unless $stdin.gets&.strip&.match?(/^[Yy]/)
      gemcheck_install(missing)
      puts 'OK'.green
    end

    def gemcheck_install(missing)
      missing.each_key do |name, major|
        req = "~> #{major}"
        next if system('gem', 'list', name, '-v', req, '-i', out: File::NULL)

        system('gem', 'install', name, '-v', req) || exit(EX_UNAVAILABLE)
      end
    end

    # :reek:FeatureEnvy :reek:TooManyStatements :reek:UtilityFunction
    def gemcheck_missing(inventory)
      current = inventory.fetch(RUBY_VERSION, {})
      missing = Hash.new { |hash, key| hash[key] = [] }
      inventory.each_pair do |version, gems|
        next if version == RUBY_VERSION

        record_missing(missing, version, missing_gems(gems, current))
      end
      missing
    end

    # :reek:NestedIterators :reek:UtilityFunction
    def missing_gems(gems, current)
      gems.each_with_object([]) do |(name, majors), diff|
        (majors - current.fetch(name, [])).each do |major|
          diff << [name, major]
        end
      end
    end

    # :reek:UtilityFunction
    def record_missing(missing, version, items)
      items.each { |key| missing[key] << version }
    end
  end
end
