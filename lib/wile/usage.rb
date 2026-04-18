# frozen_string_literal: true

# Wile namespace.
# :reek:MissingSafeMethod
module Wile
  # UsageError is raised when the usage of a task is incorrect.
  # It provides a message that includes the help information for the task.
  class UsageError < RuntimeError
    def initialize(msg = nil)
      key, message = msg.split(':', 2).map(&:strip)
      if (help = Help[key.to_sym])
        msg = help + message
      end
      super
    end
  end

  # Usage class validates the command-line arguments for a task.
  class Usage
    attr_reader :args

    def initialize(options, message, *validators)
      @args       = options.args
      @opts       = options.to_h.keys.grep(String)
                           .select { it.length > 1 }
                           .reject { %w[task args].include? it }
      @message    = message
      @validators = validators
      validate!
    end

    private

    def validate!
      @validators.each do |validator|
        raise UsageError, @message unless validator_type_check(validator)
      end
    end

    VALIDATORS = {
      Range => :include?,
      Regexp => :match?,
      Integer => :size_of?,
      Set => :allowed_opt?
    }.freeze
    private_constant :VALIDATORS

    def validator_type_check(validator)
      _, mth = VALIDATORS.detect { |type, _| validator.is_a? type }
      raise StandardError, "invalid validator: #{validator.inspect}" unless mth

      method(mth).call(validator)
    end

    def allowed_opt?(validator)
      @opts.all? { validator.include? it }
    end

    def include?(validator)
      validator.include?(@args&.size.to_i)
    end

    # :reek:NilCheck
    def match?(validator)
      @args.nil? || @args.all? { validator.match? it }
    end

    def size_of?(validator)
      validator == @args&.size.to_i
    end
  end
end
