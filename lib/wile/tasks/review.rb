# frozen_string_literal: true

# wile: require 'reek'
# wile: require 'rubocop'

# ## wile review ##
# Interactively reviews project files using content, order, reek, and rubocop.
# With --all, auto-advances through passing files and stops only on issues.
#   CSV is a comma separated list: content,order,reek,rubocop
# Usage:
#   wile review [<target>] [--all] [--strict] [--only=CSV] # runs review
module Wile
  # This file is loaded upon a :review task request.
  class Tasks
    REVIEW_USAGE = [
      'review: May take one target with optional all/strict/only flags.',
      (0..1), Set['all', 'strict', 'only']
    ].freeze

    # :reek:UtilityFunction
    def review(options, target: nil)
      Utilities.verify_project_root!
      target ||= Usage.new(options, *REVIEW_USAGE).args&.first
      Review.new(options, target:).run
    end
  end

  # This class is used to run review.
  # :reek:TooManyInstanceVariables :reek:UncommunicativeVariableName
  class Review
    using UtilitiesRefinements
    include Sysexits

    AVAILABLE_CHECKS = %i[content order reek rubocop].freeze

    # :reek:ControlParameter
    def initialize(options, target: nil, files: nil)
      @files = files || review_files(target)
      @files.weird_filename!
      @index = 0
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

    # :reek:TooManyStatements :reek:UtilityFunction
    def review_files(target)
      all_files = NvimFiles.new.nvim_files
      all_files = all_files.select { it.start_with?('lib/') }
      return all_files unless target
      return [target] if File.file?(target)
      return Dir.glob("#{target}/**/*.rb") if File.directory?(target)

      matched = all_files.grep(/#{target}/)
      raise "no match for #{target}" if matched.empty?

      matched
    end

    def index(match)
      @files.index { |entry| entry.match?(match) } or
        raise "no match for #{match}"
    end

    # :reek:TooManyStatements
    def settings(options)
      @strict = options.strict?
      @auto = options.all?
      return unless (checks = options.only)

      checks = checks.map(&:to_sym)
      bad = checks - AVAILABLE_CHECKS
      raise "Unknown checks: #{bad.join(',')}" unless bad.empty?

      @checks = checks
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
      review_next review_failed
    end

    def review_next(failed)
      review_response_cases review_choice(failed)
    rescue RuntimeError => e
      puts e.message.red
      retry
    end

    # :reek:ControlParameter :reek:TooManyStatements
    def review_choice(failed)
      passed = failed.empty?
      return @index + 1 < @files.size ? 'n' : 'q' if @auto && passed

      puts "\nFailed: #{failed.join(', ')}".red unless passed
      print 'Next(Enter) Quit(q) Redo(r) Previous(p) or file match: '.yellow
      $stdin.gets&.strip || 'q'
    end

    def review_failed
      @checks.reject { send(it) }
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
