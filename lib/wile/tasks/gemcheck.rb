# frozen_string_literal: true

# ## wile gemcheck ##
# Checks for missing gems in the current Ruby version that are found installed
# in other versions on the system using `rbenv`.
# Usage:
#   wile gemcheck # Checks for missing gems
module Wile
  # This file is loaded upon a :gemcheck task request.
  # :reek:TooManyStatements :reek:UncommunicativeVariableName
  class Tasks
    GEMCHECK_USAGE = ['gemcheck: Takes no parameters/options.', 0, Set[]].freeze

    def gemcheck(options)
      Usage.new(options, *GEMCHECK_USAGE)
      root = `rbenv root 2>/dev/null`.strip
      prefix = File.join(root, 'versions')
      gemcmd = `rbenv which gem 2>/dev/null`.strip
      unless File.directory?(prefix) && gemcmd.start_with?(prefix)
        raise "Unexpected gem command: #{gemcmd}"
      end

      gemcheck_do(prefix)
    end

    private

    def gemcheck_inventory(prefix)
      v2s = Hash.new { |h, k| h[k] = [] }
      `rbenv versions --bare --skip-aliases`.lines.each do |version|
        version.strip!
        gemcmd = "#{prefix}/#{version}/bin/gem"
        `#{gemcmd} list`.lines.map { it.strip.split(' ', 2) }.each do |name,|
          v2s[version] << name
        end
      end
      v2s
    end

    def gemcheck_report(missing)
      puts "Current Ruby version: #{RUBY_VERSION}".gray
      puts 'Gems missing in current found in other versions:'.blue
      missing.each do |name, versions|
        puts "  #{name}:  #{versions.join(', ')}"
      end
    end

    # :reek:DuplicateMethodCall 'OK'.green
    def gemcheck_do(prefix)
      missing = gemcheck_missing gemcheck_inventory(prefix)
      if missing.empty?
        puts 'OK'.green
        exit(EX_OK)
      end
      gemcheck_report missing
      puts 'Would you like to install them all? (Y/n)'.yellow
      exit(EX_NO) unless $stdin.gets&.strip&.match?(/^[Yy]/)
      gemcheck_install(missing)
      puts 'OK'.green
    end

    def gemcheck_install(missing)
      missing.each_pair do |name,|
        next if system('gem', 'list', name, '-i') # already installed

        system('gem', 'install', name) || exit(EX_UNAVAILABLE)
      end
    end

    # :reek:NestedIterators :reek:UtilityFunction
    def gemcheck_missing(v2s)
      current = v2s[RUBY_VERSION]
      missing = Hash.new { |h, k| h[k] = [] }
      v2s.each_pair do |version, set|
        next if version == RUBY_VERSION

        set.each do |name|
          next if current.include?(name)

          missing[name] << version
        end
      end
      missing
    end
  end
end
