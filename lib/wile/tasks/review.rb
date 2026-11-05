# frozen_string_literal: true

# Also:
# require 'reek'
# require 'rubocop'

# ## wile review ##
#   CSV is a comma separated list: content,order,reek,rubocop
# Usage:
#   wile review [<match>] [--strict, --only=CSV] # runs review
module Wile
  # This file is loaded upon a :review task request.
  # :reek:UtilityFunction :reek:LongParameterList
  class Tasks
    WILES_USAGE = [
      'review: May take one match with optional strict/only flags.',
      (0..1), Set['strict', 'only']
    ].freeze

    def review(options, match: nil, file: nil, files: nil)
      Utilities.verify_project_root!
      name = Usage.new(options, *WILES_USAGE).args&.first
      files, file, match = files_file_match(name) if name
      Review.new(options, match:, file:, files:).run
    end

    private

    def files_file_match(name)
      if File.directory?(name)
        [Dir.glob("#{name}/**.rb"), nil, nil]
      elsif File.file?(name)
        [nil, name, nil]
      else
        [nil, nil, name]
      end
    end
  end

  # This class is used to run review.
  # :reek:TooManyInstanceVariables :reek:UncommunicativeVariableName
  class Review
    using UtilitiesRefinements
    include Sysexits

    AVAILABLE_CHECKS = %i[content order reek rubocop].freeze

    # :reek:ControlParameter
    def initialize(options, match: nil, files: nil, file: nil)
      @files = files || NvimFiles.new.nvim_files.drop(1)
      @files.unshift(file) if file && !@files.include?(file)
      @index = target_index(file, match)
      @strict = false
      @checks = AVAILABLE_CHECKS
      @auto = false
      settings(options)
    end

    def run
      loop { review_do }
    end

    private

    def file
      @files[@index]
    end

    def target_index(file, match)
      return index(file) if file
      return index(match) || 0 if match

      0
    end

    def index(match)
      @files.index { |entry| entry.match?(match) } or
        raise "no match for #{match}"
    end

    # :reek:TooManyStatements
    def settings(options)
      @strict = options.strict?
      return unless (checks = options.only)

      checks = checks.map(&:to_sym)
      bad = checks - AVAILABLE_CHECKS
      raise "Unknown checks: #{bad.join(',')}" unless bad.empty?

      @checks = checks
      @auto = true
    end

    def review_response_cases(response, size = @files.size)
      case response
      when 'q', 'Q' then exit(EX_OK)
      when '', 'n', 'N' then @index = (@index + 1) % size
      when 'p', 'P' then @index = (@index - 1) % size
      else
        @index = index(response) unless response == 'r'
      end
    end

    def review_do
      system('clear')
      puts "#{@index + 1}. #{file}".blue.bold
      review_next review_file?
    end

    def review_next(passed)
      review_response_cases review_choice(passed)
    rescue RuntimeError => e
      puts e.message.red
      retry
    end

    # :reek:ControlParameter
    def review_choice(passed)
      return @index + 1 < @files.size ? 'n' : 'q' if @auto && passed

      print 'Next(Enter) Quit(q) Redo(r) Previous(p) or file match: '.yellow
      $stdin.gets.strip
    end

    def review_file?
      @checks.map { send(it) }.all?
    end

    def content
      puts "\n# Content".blue
      system("wile content #{file.sw}")
    end

    def order
      puts "\n# Order".blue
      sw = file.sw
      system("wile order #{sw}") && system("wile order #{sw} bprm")
    end

    def reek
      puts "\n# Reek".blue
      cfg = @strict ? '--config .reek-strict.yml' : ''
      system("reek --no-documentation #{cfg} #{file.sw}")
    end

    def rubocop
      puts "\n# Rubocop".blue
      cfg = @strict ? '--config .rubocop-strict.yml' : ''
      system("rubocop #{cfg} #{file.sw}")
    end
  end
end
