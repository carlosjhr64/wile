# frozen_string_literal: true

# wile: os `pandoc`

# Wile namespace.
module Wile
  # Generates roff man pages from markdown using pandoc.
  # :reek:MissingSafeMethod
  class Manpage
    def initialize(info = Info.info)
      @info = info
      @project = @info.project
      path = File.join(@info.dirname, 'man', @project)
      @md_path = "#{path}.md"
      @roff_path = "#{path}.1"
    end

    def exist? = File.file?(@md_path)

    def update!
      return unless exist?

      unless Utilities.command_available?('pandoc')
        warn 'Notice: pandoc not found; skipping manpage update.'.yellow
        return
      end

      Utilities.run('pandoc', *pandoc_args) { |_, msg| raise msg }
    end

    private

    def pandoc_args
      ['-s', '-f', 'markdown', '-t', 'man',
       '--shift-heading-level-by=-1',
       '-V', "title=#{@project.upcase}",
       '-V', 'section=1',
       '-V', "date=#{@info.now.strftime('%B %Y')}",
       '-V', "footer=#{@project} #{@info.version}",
       '-V', 'header=User Commands',
       @md_path, '-o', @roff_path]
    end
  end
end
