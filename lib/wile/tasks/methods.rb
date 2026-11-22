# frozen_string_literal: true

# ## wile methods ##
# Classify methods in your code:
# * Undefined: methods that are not defined in your code
# * Implicit: constructors that are called but not defined
# * Unused: methods that are defined but not used
# * Independent: methods that do not depend on other methods
# * Isolate: methods that are not used and do not depend on other methods
# * Shared: methods that are used by other files
# * Reused: method names that are used by multiple classes
# Usage:
#   wile methods [match+] [--name=list-name] # classify methods in your code
module Wile
  # This file is loaded upon a :methods task request.
  class Tasks
    METHODS_USAGE = ['methods: Optionally takes one or more arguments.',
                     Set['name']].freeze

    def methods(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      matches = Usage.new(options, *METHODS_USAGE).args&.map { Regexp.new(it) }
      DisplayLists.new(matches, select: options.name).display
    end
  end

  # Displays categorized method lists.
  class DisplayLists
    using WileRefinements

    LISTS = %i[
      undefined implicit unused independent isolate shared reused
    ].freeze

    def initialize(matches = nil, select: nil, methods: Methods.new)
      @matches = matches
      @select = select&.downcase
      @methods = methods
    end

    def display
      puts "# Matching: #{@matches.map(&:inspect).join(', ')}".blue if @matches
      puts
      LISTS.each { send(it) if selected?(it) }
    end

    def self.label_undefined(mth)
      return "#{mth} ☰".magenta if mth.standard_library? # UTF-8
      return "#{mth} ◇".cyan if mth.object_method? # UTF-8

      mth
    end

    private

    def selected?(name)
      !@select || name.match?(@select)
    end

    # category: lists

    def isolate
      list = @methods.methods
                     .select do |name, info|
                       match?(name) && info.dependencies.empty? &&
                         info.dependants.empty?
                     end
                     .keys.sort
      display_list(list, '## Isolate ##'.blue)
    end

    def shared
      list = @methods.methods
                     .select do |name, info|
                       match?(name) &&
                         info.dependants.any? { it != info.filename }
                     end
                     .keys.sort
      display_list(list, '## Shared ##'.blue)
    end

    def undefined
      list = @methods.undefined_methods.select { match?(it) }.sort
      list.map! { DisplayLists.label_undefined(it) }
      display_list(list, '## Undefined ##'.blue)
    end

    def unused
      list = @methods.methods
                     .select do |name, info|
                       match?(name) && info.dependants.empty?
                     end
                     .keys.sort
      display_list(list, '## Unused ##'.blue)
    end

    def independent
      list = @methods.methods
                     .select do |name, info|
                       match?(name) && info.dependencies.empty?
                     end
                     .keys.sort
      display_list(list, '## Independent ##'.blue)
    end

    def implicit
      list = @methods.implicit_methods.select { match?(it) }.sort
      display_list(list, '## Implicit ##'.blue)
    end

    def reused
      reused = name2scope.select! do |name, scopes|
        scopes.size > 1 and name != 'initialize' and match?(name)
      end
      display_reused(reused) unless reused.empty?
    end

    # category: helper

    def match?(name)
      !@matches || @matches.any? { it.match?(name) }
    end

    def name2scope
      @methods.methods.each_key.with_object({}) do |mth, scopes|
        name, dot, scope = mth.split(/([.#])/).reverse
        (scopes[name] ||= []) << "#{scope}#{dot}"
      end
    end

    # category: display

    def display_list(list, heading = nil)
      return if list.empty?

      puts heading if heading
      list.display
      puts
    end

    def display_reused(reused)
      puts '## Reused ##'.blue
      reused.each do |name, scopes|
        puts "#{name.bold}:"
        scopes.display
      end
      puts
    end
  end
end
