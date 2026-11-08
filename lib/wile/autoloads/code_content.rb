# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeContent class generates code content for the Wile framework.
  # :reek:InstanceVariableAssumption
  # :reek:TooManyInstanceVariables :reek:TooManyMethods
  class CodeContent < Prism::Visitor
    CASGN_TYPES = {
      array_node: 'array', float_node: 'float', hash_node: 'hash',
      integer_node: 'int', interpolated_regular_expression_node: 'regexp',
      interpolated_string_node: 'dstr', interpolated_symbol_node: 'sym',
      keyword_hash_node: 'hash', lambda_node: 'lambda',
      regular_expression_node: 'regexp', string_node: 'str', symbol_node: 'sym'
    }.freeze

    CALL_NAME = /\A(?:\w+[!=?]?|\[\])\z/
    CONST_CALL = /\A[a-z]\w*[!=?]?\z/
    CONST_NODES = [Prism::ConstantReadNode, Prism::ConstantPathNode].freeze

    private_constant :CASGN_TYPES, :CALL_NAME, :CONST_CALL, :CONST_NODES

    def self.ast(fnm) = Prism::Translation::Parser.parse_file(fnm).inspect.lines

    def self.generate(filename, &) = new.generate(filename, &)

    def generate(fnm, &blk)
      vset(blk, nil, '#', Set.new, [])
      Prism.parse_file(fnm).value.accept(self)
    ensure
      vset
    end

    def visit_def_node(node, receiver = node.receiver)
      return if receiver && !receiver.is_a?(Prism::SelfNode)

      @dot = '.' if receiver || @scope.last == '.'
      def_body(node.name_loc.slice) { super(node) }
    end

    def visit_module_node(node)
      with_scope(node.constant_path.slice.delete_prefix('::')) { super }
    end
    alias visit_class_node visit_module_node

    def visit_singleton_class_node(_node)
      with_scope('.') { super }
    end

    def visit_call_node(node)
      receiver = node.receiver
      name = node.name
      return visit_refine(node) if !receiver && name == :refine && node.block

      handle_call(receiver, name)
      super
    end

    def visit_constant_path_write_node(node)
      emit_casgn(node.target.slice.delete_prefix('::'), node)
    end

    def visit_lambda_node(node)
      emit_call("#{@dot}lambda")
      super
    end

    def visit_constant_write_node(node)
      emit_casgn([scope_str, node.name].reject(&:empty?).join('::'), node)
    end

    private

    def vset(*args)
      @block, @dependencies, @dot, @main, @scope = args
    end

    def with_scope(*names)
      @scope.push(*names)
      yield
    ensure
      names.size.times { @scope.pop }
    end

    def visit_refine(node, target = node.arguments.arguments.first.slice)
      scopes = target.delete_prefix('::').sub('.singleton_class', ' .').split
      with_scope(*scopes) { visit(node.block) }
    end

    def scope_str = @scope.reject { it == '.' }.join('::')

    def def_body(name)
      @dependencies = Set.new
      @block["def #{scope_str}#{@dot}#{name}"]
      yield
    ensure
      @dot = '#'
      @dependencies = nil
      @block['end']
    end

    # :reek:FeatureEnvy
    def emit_casgn(full, node, val = node.value)
      while val.is_a?(Prism::CallNode)
        return @block["casgn #{full} #{val.name}"] unless
          (receiver = val.receiver)

        val = receiver
      end
      type = CASGN_TYPES[val.type] || val.slice.delete_prefix('::')
      @block["casgn #{full} #{type}"]
    end

    def handle_call(receiver, name)
      if !receiver && CALL_NAME.match?(name)
        emit_call("#{@dot}#{name}")
      elsif CONST_NODES.include?(receiver.class) && CONST_CALL.match?(name)
        emit_call("#{receiver.slice.delete_prefix('::')}.#{name}")
      end
    end

    def emit_call(name)
      if @dependencies
        @block["  #{name}"] unless @dependencies.include?(name)
        @dependencies.add(name)
      else
        @block[name] unless @main.include?(name)
        @main.add(name)
      end
    end
  end
end
