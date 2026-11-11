# frozen_string_literal: true

# ## wile gemcheck ##
# Checks for missing gems in the current Ruby version that are found installed
# in other versions on the system using `rbenv`.
# Usage:
#   wile gemcheck [--all] # Checks for missing gems
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
      inventory = {}
      target_versions(all:).each do |ver|
        gemcmd = File.join(prefix, ver, 'bin/gem')
        inventory[ver] = collect_gems(gemcmd) if File.executable?(gemcmd)
      end
      inventory
    end

    # :reek:BooleanParameter :reek:ControlParameter :reek:UtilityFunction
    def target_versions(all: false)
      versions = `rbenv versions --bare --skip-aliases`.lines(chomp: true)
      return versions if all

      prev = previous_version(versions)
      [RUBY_VERSION, prev].compact.uniq
    end

    # :reek:TooManyStatements :reek:UtilityFunction
    def previous_version(versions, current = RUBY_VERSION)
      valid = versions.select { Gem::Version.correct?(it) }
      sorted = (valid + [current]).uniq.sort_by { Gem::Version.new(it) }
      idx = sorted.index(current)
      idx&.positive? ? sorted[idx - 1] : nil
    end

    # :reek:UtilityFunction
    def collect_gems(gemcmd)
      `#{gemcmd} list`.lines(chomp: true).each_with_object({}) do |line, gems|
        name, vers = line.split(' ', 2)
        major = gem_major(vers)
        gems[name] = major if major
      end
    end

    # :reek:UtilityFunction
    def gem_major(str)
      return unless str&.start_with?('(') && str.end_with?(')')

      str[1..-2].split(',').filter_map do |item|
        ver = item.sub('default:', '').strip.split.first
        Gem::Version.new(ver).segments.first if Gem::Version.correct?(ver)
      end.max
    end

    def gemcheck_report(missing, searched)
      puts "Current Ruby version: #{RUBY_VERSION}".gray
      puts "Searching versions:   #{searched.join(', ')}".gray
      puts 'Gems missing in current found in other versions:'.blue
      missing.each do |name, (major, versions)|
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
      missing.each do |name, (major)|
        req = "~> #{major}"
        next if system('gem', 'list', name, '-v', req, '-i', out: File::NULL)

        system('gem', 'install', name, '-v', req) || exit(EX_UNAVAILABLE)
      end
    end

    # :reek:FeatureEnvy :reek:NestedIterators :reek:TooManyStatements
    # :reek:UtilityFunction
    def gemcheck_missing(inventory)
      current = inventory.fetch(RUBY_VERSION, {})
      missing = Hash.new { |hash, key| hash[key] = [-1, []] }
      inventory.each_pair do |version, gems|
        next if version == RUBY_VERSION

        gems.each_pair do |name, major|
          next if current.key?(name)

          record_missing(missing[name], version, major)
        end
      end
      missing
    end

    # :reek:UtilityFunction
    def record_missing(entry, version, major)
      entry[0] = [entry[0], major].max
      entry[1] << version
    end
  end
end
