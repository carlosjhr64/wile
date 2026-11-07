# frozen_string_literal: true

# ## wile content ##
# Options:
#   --dump       dumps SEXP
#   --raw        simple output
# Usage:
#   wile content <filename>+ [--dump] [--raw] # show file's contents
module Wile
  # This file is loaded upon a :content task request.
  class Tasks
    CONTENT_USAGE = ['content: Takes one or more filenames.',
                     %r{^[-\w./]+$}, (1..), Set['dump', 'raw']].freeze

    def content(options)
      files = content_files(options)
      return content_dump(files) if options.dump?

      exit(EX_FAIL) if Content.new(files, options).red?
    end

    private

    def content_files(options)
      raise UsageError, 'content: Cannot combine --dump and --raw.' if
        options.dump? && options.raw?

      files = Usage.new(options, *CONTENT_USAGE).args.select do |filename|
        File.file?(filename) || warn("File not found: #{filename}".red)
      end
      raise 'No files selected.' if files.empty?

      files
    end

    def content_dump(filenames)
      filenames.each do |filename|
        warn "#{'#'.gray} #{filename.blue.bold}"
        puts CodeContent.ast(filename)
      end
    end
  end
end
