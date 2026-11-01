# frozen_string_literal: true

# Wile namespace.
module Wile
  # Generates roff man pages from markdown using pandoc.
  # :reek:MissingSafeMethod
  class Manpage
    def initialize(info = Info.info)
      @info = info
      @project = @info.project
      @md_path = "man/#{@project}.md"
      @roff_path = "man/#{@project}.1"
    end

    def exist?
      File.file?(@md_path)
    end

    def update!
      return unless exist?

      unless pandoc?
        warn 'Notice: pandoc not found; skipping manpage update.'.yellow
        return
      end

      system(*pandoc_cmd)
    end

    private

    def pandoc_cmd
      ['pandoc', '-s', '-f', 'markdown', '-t', 'man',
       '--shift-heading-level-by=-1',
       '-V', "title=#{@project.upcase}",
       '-V', 'section=1',
       '-V', "date=#{@info.now.strftime('%B %Y')}",
       '-V', "footer=#{@project} #{@info.version}",
       '-V', 'header=User Commands',
       @md_path, '-o', @roff_path]
    end

    def pandoc?
      system('which pandoc', out: File::NULL, err: File::NULL)
    end
  end
end
