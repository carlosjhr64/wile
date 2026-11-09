# frozen_string_literal: true

# ## wile smell ##
# Classify methods in your code:
# * Undefined: methods that are not defined in your code
# * Implicit: constructors that are called but not defined
# * Unused: methods that are defined but not used
# * Independent: methods that are used but do not depend on other methods
# * Isolate: methods that are not used and do not depend on other methods
# * Shared: methods that are used by other files
# * Reused: method names that are used by multiple classes
# Usage:
#   wile smell [match+] [--name=list-name] # classify methods in your code
module Wile
  # This file is loaded upon a :smell task request.
  class Tasks
    SMELL_USAGE = ['smell: Optionally takes one or more arguments.',
                   Set['name']].freeze

    def smell(options)
      Utilities.verify_project_root!
      matches = Usage.new(options, *SMELL_USAGE).args&.map { Regexp.new(it) }
      DisplayLists.new(matches, select: options.name).display
    end
  end

  # Displays categorized smell lists.
  # :reek:NilCheck
  class DisplayLists
    using WileRefinements

    LISTS = %i[
      undefined implicit unused independent isolate shared reused
    ].freeze

    def initialize(matches = nil, select: nil, smell: Smell.new)
      @matches = matches
      @select = select&.downcase
      @smell = smell
    end

    def display
      puts "# Matching: #{@matches.map(&:inspect).join(', ')}".blue if @matches
      puts
      LISTS.each { send(it) if selected?(it) }
    end

    private

    def selected?(name)
      @select.nil? || name.match?(@select)
    end

    def match?(name)
      @matches.nil? || @matches.any? { it.match?(name) }
    end

    # :reek:TooManyStatements
    def name2scope
      scopes = Hash.new { |hash, name| hash[name] = [] }
      @smell.methods.each_key do |mth|
        name, dot, scope = mth.split(/([.#])/).reverse
        scopes[name] << "#{scope}#{dot}"
      end
      scopes
    end

    def reused
      reused = name2scope.select! do |name, scopes|
        scopes.size > 1 and name != 'initialize' and match?(name)
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

    def isolate
      list = @smell.methods
                   .select do |name, info|
                     match?(name) && info.dependencies.empty? &&
                       info.dependants.empty?
                   end
                   .keys.sort
      display_list(list, '## Isolate ##'.blue)
    end

    def shared
      list = @smell.methods
                   .select do |name, info|
                     match?(name) &&
                       info.dependants.any? { it != info.filename }
                   end
                   .keys.sort
      display_list(list, '## Shared ##'.blue)
    end

    def unused
      list = @smell.methods
                   .select do |name, info|
                     match?(name) && info.dependants.empty?
                   end
                   .keys.sort
      display_list(list, '## Unused ##'.blue)
    end

    def independent
      list = @smell.methods
                   .select do |name, info|
                     match?(name) && info.dependencies.empty?
                   end
                   .keys.sort
      display_list(list, '## Independent ##'.blue)
    end

    def undefined
      list = @smell.undefined_methods.select { match?(it) }.sort
      display_list(list, '## Undefined ##'.blue)
    end

    def implicit
      list = @smell.implicit_methods.select { match?(it) }.sort
      display_list(list, '## Implicit ##'.blue)
    end

    def display_list(list, heading = nil)
      return if list.empty?

      puts heading if heading
      list.display
      puts
    end
  end
end
