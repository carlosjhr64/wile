# frozen_string_literal: true

# ## wile content ##
# Options:
#   -d, --dump   dumps AST
#   -r, --raw    simple output
# Usage:
#   wile content <filename>+ [:option] # show file's contents
module Wile
  # This file is loaded upon a :content task request.
  class Tasks
    CONTENT_USAGE = ['content: Takes one or more filenames.',
                     %r{^[-\w./]+$}, (1..), Set['dump', 'raw']].freeze

    def content(options)
      files = Usage.new(options, *CONTENT_USAGE).args.select do |filename|
        File.exist?(filename) || warn("File not found: #{filename}".red)
      end
      raise 'No files selected.' if files.empty?

      if options.dump? then content_dump(files)
      elsif Content.new(files, options).red? then exit(EX_FAIL)
      end
    end

    private

    def content_dump(filenames)
      filenames.each do |filename|
        warn "#{'#'.gray} #{filename.blue.bold}"
        puts CodeContent.ast(filename)
      end
    end
  end
end
