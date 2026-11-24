# frozen_string_literal: true

# ## wile info ##
# Show as much info as found in gemspec.
# Usage:
#   wile info # show project info
module Wile
  # This file is loaded upon a :info task request.
  class Tasks
    INFO_USAGE = ['info: Takes no arguments.', 0, Set[]].freeze

    def info(options, info = Info.info)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *INFO_USAGE)
      InfoDisplay.new(info).display
    end
  end

  # Displays project metadata, README description, and gemspec sections.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::InfoDisplay
    def initialize(info = Info.info)
      @info = info
    end

    def self.gem_label(gem)
      name = gem.name
      ver = gem.version
      ver ? "#{name}(#{ver})" : name
    end

    def display
      puts_header
      puts_readme
      puts_gemspec
    end

    private

    def puts_gems(heading, gems)
      puts_section(heading, gems.map { self.class.gem_label(it) })
    end

    def puts_section(heading, items)
      puts "#{heading.blue}\n#{items.map { "* #{it}" }.join("\n")}"
    end

    def puts_gemspec
      gemspec = Gemspec.new(@info)
      puts_section('## Files', gemspec.files)
      puts_section('## Executables', gemspec.executables)
      puts_gems('## Runtime gems', gemspec.rungems)
      puts_gems('## Development gems', gemspec.devgems)
    end

    def puts_header
      puts <<~INFO
        # #{@info.project.blue.bold}
        + Version: #{@info.version}
        + Author:  #{@info.username}
      INFO
    end

    def puts_readme
      readme = Readme.new(@info)
      puts <<~README
        #{'## Description'.blue}
        #{readme.description.light_black}
      README
    rescue StandardError
      nil
    end
  end
  Tasks.private_constant :InfoDisplay
end
