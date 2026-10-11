# frozen_string_literal: true

# ## wile review ##
#   CSV is a comma separated list: content,order,reek,rubocop
# Usage:
#   wile review [<match>] [--strict, --check=CSV] # runs review
module Wile
  # This file is loaded upon a :review task request.
  # :reek:UtilityFunction :reek:LongParameterList
  class Tasks
    WILES_USAGE = [
      'review: May take one match with optional strict/check flag.',
      (0..1), Set['strict', 'check']
    ].freeze

    def review(options, match: nil, file: nil, files: nil)
      name = Usage.new(options, *WILES_USAGE).args&.first
      files, file, match = files_file_match(name) if name
      Review.new(options, match:, file:, files:)
    end

    private

    def files_file_match(name, files = nil, file = nil, match = nil)
      if File.directory?(name)
        files = Dir.glob("#{name}/**.rb")
      elsif File.file?(name)
        file = name
      else
        match = name
      end
      [files, file, match]
    end
  end

  # This class is used to run review.
  # :reek:TooManyInstanceVariables :reek:UncommunicativeVariableName
  # rubocop:disable Metrics/MethodLength
  class Review
    # :reek:ControlParameter
    def initialize(options, match: nil, files: nil, file: nil)
      @files = files || NvimFiles.new.nvim_files.tap(&:shift)
      if file
        @files.unshift(file) unless @files.include?(file)
        @i = index(file)
      else
        @i = match ? (index(match) || 0) : 0
      end
      @file = @files[@i]
      @strict = false
      @checks = %i[content order reek rubocop]
      @auto = false
      settings(options)
      loop { review_do }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def index(match)
      @files.index { |file| file.match?(match) } or
        raise "no match for #{match}"
    end

    # :reek:TooManyStatements
    def settings(options)
      @strict = options.strict?
      if (checks = options.check)
        if checks.is_a?(String)
          checks = checks.split(',').map(&:to_sym)
          bad = checks - @checks
          raise "Unknown checks: #{bad.join(',')}" unless bad.empty?

          @checks = checks
        end
        @auto = true
      end
    end

    def review_responce_cases(responce, size = @files.size)
      case responce
      when 'q', 'Q' then exit
      when '', 'n', 'N' then @i = (@i + 1) % size
      when 'p', 'P' then @i = (@i - 1) % size
      else
        @i = index(responce) unless responce == 'r'
      end
      @file = @files[@i]
    end

    def review_do
      system('clear')
      puts "#{@i + 1}. #{@file}"
      review_next review_file
    end

    def review_next(passed)
      review_responce_cases review_choice(passed)
    rescue RuntimeError => e
      puts e.message.red
      retry
    end

    # :reek:ControlParameter
    def review_choice(passed)
      return @i + 1 < @files.size ? 'n' : 'q' if @auto && passed

      print 'Next(Enter) Quit(q) Redo(r) Previous(p) or file match: '
      $stdin.gets.strip
    end

    def review_file
      ok = true
      @checks.each do |check|
        send(check) or ok = false
      end
      ok
    end

    def content
      puts "\n# Content".blue
      file = Shellwords.escape(@file)
      system("wile content #{file}")
    end

    def order
      puts "\n# Order".blue
      file = Shellwords.escape(@file)
      system("wile order #{file}") && system("wile order #{file} bprm")
    end

    def reek
      puts "\n# Reek".blue
      file = Shellwords.escape(@file)
      system("reek --no-documentation #{config('reek')} #{file}")
    end

    def config(name)
      @strict ? "--config .#{name}-strict.yml" : ''
    end

    def rubocop
      puts "\n# Rubocop".blue
      file = Shellwords.escape(@file)
      system("rubocop #{config('rubocop')} #{file}")
    end
  end
end
