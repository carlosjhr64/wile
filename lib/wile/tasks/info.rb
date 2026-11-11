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
      Utilities.verify_project_root!
      Usage.new(options, *INFO_USAGE)
      puts_info(info)
      puts_readme(Readme.new(info))
      puts_gemspec(Gemspec.new(info))
    end

    private

    # category: info

    # :reek:FeatureEnvy
    def puts_info(info)
      project = info.project
      puts <<~INFO
        # #{project.blue.bold}
        + Version: #{info.version}
        + Author:  #{info.username}
      INFO
    end

    # category: readme

    def puts_readme(readme)
      puts <<~README
        #{'## Description'.blue}
        #{readme.description.light_black}
      README
    rescue StandardError
      nil
    end

    # category: gemspec

    def puts_gemspec(gemspec)
      puts_gemspec_files(gemspec.files)
      puts_gemspec_executables(gemspec.executables)
      puts_gemspec_runtime(gemspec.rungems)
      puts_gemspec_development(gemspec.devgems)
    end

    # category: gemspec_parts

    def puts_gemspec_files(files)
      puts <<~GEMSPEC_FILES
        #{'## Files'.blue}
        #{files.map { "* #{it}" }.join("\n")}
      GEMSPEC_FILES
    end

    def puts_gemspec_executables(executables)
      puts <<~GEMSPEC_EXECUTABLES
        #{'## Executables'.blue}
        #{executables.map { "* #{it}" }.join("\n")}
      GEMSPEC_EXECUTABLES
    end

    def puts_gemspec_runtime(rungems)
      puts <<~GEMSPEC_RUNTIME
        #{'## Runtime gems'.blue}
        #{rungems.map { "* #{gem_label(it)}" }.join("\n")}
      GEMSPEC_RUNTIME
    end

    def puts_gemspec_development(devgems)
      puts <<~GEMSPEC_DEVELOPMENT
        #{'## Development gems'.blue}
        #{devgems.map { "* #{gem_label(it)}" }.join("\n")}
      GEMSPEC_DEVELOPMENT
    end

    # :reek:UtilityFunction
    def gem_label(gem)
      name = gem.name
      ver = gem.version
      ver ? "#{name}(#{ver})" : name
    end
  end
end
