# frozen_string_literal: true

# Wile namespace.
module Wile
  # UsageError is raised when the usage of a task is incorrect.
  # It provides a message that includes the help information for the task.
  class UsageError < RuntimeError
    def initialize(msg = $ERROR_INFO&.message)
      if msg
        key, message = msg.split(':', 2).map(&:strip)
        if message && (help = Help[key.to_sym])
          msg = help + message
        end
      end
      super
    end
  end

  # Usage class validates the command-line arguments for a task.
  # :reek:MissingSafeMethod
  class Usage
    attr_reader :args

    def initialize(options, message, *validators)
      keys        = options.to_h.keys
      @args       = options.args
      @opts       = keys.grep(String).select { it.length > 1 } - %w[task args]
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
      Range => :in_range?,
      Regexp => :match?,
      Integer => :size_of?,
      Set => :allowed_opt?
    }.freeze
    private_constant :VALIDATORS

    def validator_type_check(validator)
      _, mth = VALIDATORS.detect { |type, _| validator.is_a? type }
      raise ArgumentError, "invalid validator: #{validator.inspect}" unless mth

      send(mth, validator)
    end

    def allowed_opt?(validator)
      @opts.all? { validator.include? it }
    end

    def in_range?(validator)
      validator.include?(args_size)
    end

    # :reek:NilCheck
    def match?(validator)
      @args.nil? || @args.all? { validator.match? it }
    end

    def size_of?(validator)
      validator == args_size
    end

    def args_size
      @args&.size.to_i
    end
  end
end
