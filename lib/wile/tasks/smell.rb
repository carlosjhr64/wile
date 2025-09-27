# frozen_string_literal: true

# ## wile smell ##
# Classify methods in your code:
# * Undefined: methods that are not defined in your code
# * Unused: methods that are defined but not used
# * Independent: methods that are used but do not depend on other methods
# * Isolate: methods that are not used and do not depend on other methods
# * Shared: methods that are used by other files
# * Reused: method names that are used by multiple classes
# Usage:
#   wile smell [match+] [--name=list-name] # classify methods in your code
module Wile
  # This file is loaded upon a :smell task request.
  # :reek:UncommunicativeVariableName :reek:NilCheck
  # :reek:DataClump match smell
  class Tasks
    using Refinement

    SMELL_USAGE = ['smell: Optionally takes one or more arguments.',
                   Set['name']].freeze

    # :reek:TooManyStatements
    def smell(options)
      matches = Usage.new(options, *SMELL_USAGE).args&.map { Regexp.new(it) }
      smell = Smell.new
      select = options.name&.downcase
      list = select ? ->(name) { name.match? select } : ->(_) { true }
      display(smell, matches, &list)
    end

    private

    LISTS = %i[undefined unused independent isolate shared reused].freeze
    private_constant :LISTS

    def display(smell, matches)
      puts "# Matching: #{matches.map(&:inspect).join(', ')}".blue if matches
      puts
      LISTS.each do |list|
        method(list).call(smell, matches) if yield list
      end
    end

    # :reek:UtilityFunction :reek:TooManyStatements
    def name2scope(smell)
      n2s = Hash.new { |hash, name| hash[name] = [] }
      smell.methods.keys.map do |mth|
        name, dot, scope = mth.split(/([.#])/).reverse
        n2s[name] << "#{scope}#{dot}"
      end
      n2s
    end

    def reused(smell, match)
      reused = name2scope(smell).select! do |name, scopes|
        scopes.size > 1 and name != 'initialize' and
          (match.nil? || match.any? { it.match? name })
      end
      display_reused(reused) unless reused.empty?
    end

    def display_reused(reused)
      puts '## Reused ##'.blue
      reused.each do |name, scopes|
        puts "#{name.bold}:"
        scopes.display
      end
      puts
    end

    # :reek:UtilityFunction
    def isolate_methods(smell)
      smell.methods
           .select { |_, i| i.dependencies.empty? && i.dependants.empty? }
           .map { |m,| m }
    end

    # :reek:FeatureEnvy
    def shared_methods(smell)
      smell.methods
           .select { |_, i| i.dependants.any? { it != i.filename } }
           .map { |m,| m }
    end

    def isolate(smell, match)
      list = isolate_methods(smell).sort
      list.select! { |m| match.any? { it.match? m } } if match
      display_list(list, '## Isolate ##'.blue)
    end

    def shared(smell, match)
      list = shared_methods(smell).sort
      list.select! { |m| match.any? { it.match? m } } if match
      display_list(list, '## Shared ##'.blue)
    end

    # :reek:TooManyStatements
    def unused(smell, match)
      list = smell.methods
                  .select { |m,| match.nil? || match.any? { it.match? m } }
                  .select { |_, i| i.dependants.empty? }
                  .map { |m,| m }.sort
      display_list(list, '## Unused ##'.blue)
    end

    def display_list(list, heading = nil)
      return if list.empty?

      puts heading if heading
      list.display
      puts
    end

    # :reek:TooManyStatements
    def independent(smell, match)
      list = smell.methods
                  .select { |m,| match.nil? || match.any? { it.match? m } }
                  .select { |_, i| i.dependencies.empty? }
                  .map { |m,| m }.sort
      display_list(list, '## Independent ##'.blue)
    end

    def undefined(smell, match)
      list = smell.undefined_methods
                  .select { |m| match.nil? || match.any? { it.match? m } }.sort
                  .map { it.colorize(color(it)) }
      display_list(list, '## Undefined ##'.blue)
    end

    CLASSY = Class.public_methods
    private_constant :CLASSY

    # :reek:ControlParameter and :reek:UtilityFunction
    def color(mth)
      if /^[A-Z]\w*\.(?<name>\w+[!=?]?)$/ =~ mth && CLASSY.include?(name.to_sym)
        :normal
      else
        :red
      end
    end
  end
end
