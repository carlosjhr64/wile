# frozen_string_literal: true

# ## wile info ##
# Show much info as found in gemspec.
# Usage:
#   wile info # show project info
module Wile
  # This file is loaded upon a :info task request.
  class Tasks
    INFO_USAGE = ['info: Takes no arguments.', 0, Set[]].freeze

    # :reek:TooManyStatements
    def info(options)
      Usage.new(options, *INFO_USAGE)
      info = Info.info
      readme = Readme.new(info)
      gemspec = Gemspec.new(info)
      puts_info(info)
      puts_readme(readme)
      puts_gemspec(gemspec)
    end

    private

    # category: info

    # :reek:FeatureEnvy
    def puts_info(info)
      puts <<~INFO
        # #{info.project.magenta}
        + Version: #{info.version.magenta}
        + Author:  #{info.username.magenta}
      INFO
    end

    # category: readme

    def puts_readme(readme)
      puts <<~README
        ## Description
        #{readme.description.light_black}
      README
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
        ## Files
        #{files.map { "* #{it.blue}" }.join("\n")}
      GEMSPEC_FILES
    end

    def puts_gemspec_executables(executables)
      puts <<~GEMSPEC_EXECUTABLES
        ## Executables
        #{executables.map { "* #{it.red}" }.join("\n")}
      GEMSPEC_EXECUTABLES
    end

    def puts_gemspec_runtime(rungems)
      puts <<~GEMSPEC_RUNTIME
        ## Runtime gems
        #{rungems.map { "* #{it.name.magenta}(#{it.version.blue})" }.join("\n")}
      GEMSPEC_RUNTIME
    end

    def puts_gemspec_development(devgems)
      puts <<~GEMSPEC_DEVELOPMENT
        ## Development gems
        #{devgems.map { "* #{it.name.magenta}(#{it.version.blue})" }.join("\n")}
      GEMSPEC_DEVELOPMENT
    end
  end
end
