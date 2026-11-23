# frozen_string_literal: true

# Wile namespace.
module Wile
  CASGN_TYPES = {
    array_node: 'array', float_node: 'float', hash_node: 'hash',
    integer_node: 'int', interpolated_regular_expression_node: 'regexp',
    interpolated_string_node: 'dstr', interpolated_symbol_node: 'sym',
    keyword_hash_node: 'hash', lambda_node: 'lambda',
    regular_expression_node: 'regexp', string_node: 'str', symbol_node: 'sym'
  }.freeze

  ATTR_SUFFIXES = {
    attr_reader: [''], attr_writer: ['='], attr_accessor: ['', '=']
  }.freeze
  CALL_NAME = /\A(?:\w+[!=?]?|\[\])\z/
  DUCK_NAME = /\A(?:[@$]{1,2})?[a-z_]\w*\z/
  CONST_NODES = [Prism::ConstantReadNode, Prism::ConstantPathNode].freeze

  private_constant :ATTR_SUFFIXES, :CASGN_TYPES, :CALL_NAME, :DUCK_NAME,
                   :CONST_NODES

  # Tracks lexical scope and emits deduplicated content lines.
  class ContentEmitter
    attr_reader :dot

    def initialize(block)
      @block = block
      @dot = '#'
      @scope = []
      @seen = [Set.new]
    end

    def with_scope(*names)
      @scope.push(*names)
      yield
    ensure
      names.size.times { @scope.pop }
    end

    def self.casgn_type(val_)
      while val_.is_a?(Prism::CallNode)
        return val_.name unless (receiver_ = val_.receiver)

        val_ = receiver_
      end
      CASGN_TYPES[val_.type] || val_.slice.delete_prefix('::')
    end

    def emit_casgn(full, val_)
      type = ContentEmitter.casgn_type(val_)
      @block["casgn #{full} #{type}"]
      type
    end

    def def_scope(receiver_)
      return scope_str unless CONST_NODES.include?(receiver_&.class)

      named = receiver_.slice.delete_prefix('::')
      return scope_str if scope_str.split('::').last == named
      return named if scope_str.empty? || named.start_with?(scope_str)

      "#{scope_str}::#{named}"
    end

    def scope_str = @scope.reject { it == '.' }.join('::')

    def singleton_scope? = @scope.last == '.'

    def emit_attrs(macro, node_)
      prefix = "##{macro} #{scope_str}#{singleton_scope? ? '.' : '#'}"
      syms = (node_.arguments&.arguments || []).grep(Prism::SymbolNode)
      syms.product(ATTR_SUFFIXES[macro]).each do |sym_, sfx|
        emit_call("#{prefix}#{sym_.unescaped}#{sfx}")
      end
    end

    def def_body(method_name, receiver_)
      @dot = '.' if receiver_ || singleton_scope?
      @seen.push(Set.new)
      @block["def #{def_scope(receiver_)}#{@dot}#{method_name}"]
      yield
    ensure
      leave_def
    end

    def emit_call(name)
      prefix = @seen.size > 1 ? '  ' : ''
      @block["#{prefix}#{name}"] if @seen.last.add?(name)
    end

    def handle_call(receiver_, name)
      return emit_call("#{@dot}#{name}") unless receiver_

      emit_receiver_call(receiver_, name)
    end

    private

    def leave_def
      @dot = '#'
      @seen.pop
      @block['end']
    end

    def emit_receiver_call(receiver_, name)
      slice = receiver_.slice
      if CONST_NODES.include?(receiver_.class)
        emit_call("#{slice.delete_prefix('::')}.#{name}")
      elsif slice == 'new'
        emit_call("#{@dot}new")
        emit_call("##{name}")
      else
        emit_call("#{slice[DUCK_NAME] || '*'}##{name}")
      end
    end
  end

  # CodeContent class generates code content for the Wile framework.
  # :reek:InstanceVariableAssumption
  class CodeContent < Prism::Visitor
    def generate(fnm, &blk)
      @emitter = ContentEmitter.new(blk)
      Prism.parse_file(fnm).value.accept(self)
    ensure
      @emitter = nil
    end

    def self.generate(filename, &) = new.generate(filename, &)

    def visit_def_node(node_, receiver_ = node_.receiver)
      return super(node_) if receiver_ && !receiver_.is_a?(Prism::SelfNode) &&
                             !CONST_NODES.include?(receiver_.class)

      @emitter.def_body(node_.name_loc.slice, receiver_) { super(node_) }
    end

    def visit_lambda_node(node_)
      @emitter.emit_call("#{@emitter.dot}lambda")
      super
    end

    def visit_module_node(node_)
      @emitter.with_scope(node_.constant_path.slice.delete_prefix('::')) do
        super
      end
    end
    alias visit_class_node visit_module_node

    def visit_singleton_class_node(_node)
      @emitter.with_scope('.') { super }
    end

    def self.ast(fnm) = Prism::Translation::Parser.parse_file(fnm).inspect.lines

    def visit_call_node(node_)
      receiver_ = node_.receiver
      name = node_.name
      return if !receiver_ && special_call?(node_, name)

      @emitter.handle_call(receiver_, name) if CALL_NAME.match?(name)
      super
    end

    def visit_constant_write_node(node_)
      full = [@emitter.scope_str, node_.name].reject(&:empty?).join('::')
      emit_casgn(full, node_)
    end

    def visit_constant_path_write_node(node_)
      emit_casgn(node_.target.slice.delete_prefix('::'), node_)
    end

    private

    def emit_casgn(full, node_)
      val_ = node_.value
      type = @emitter.emit_casgn(full, val_)
      emit_struct(full, val_) if type == 'Struct'
    end

    def special_call?(node_, name)
      return visit_refine(node_) || true if name == :refine && node_.block
      return false unless ATTR_SUFFIXES.key?(name)

      @emitter.emit_attrs(name, node_)
      true
    end

    def visit_refine(node_, target = node_.arguments.arguments.first.slice)
      scopes = target.delete_prefix('::').sub('.singleton_class', ' .').split
      @emitter.with_scope(*scopes) { node_.block.accept(self) }
    end

    def emit_struct(full, call_)
      return unless call_.is_a?(Prism::CallNode) && call_.name == :new

      @emitter.with_scope(full.delete_prefix("#{@emitter.scope_str}::")) do
        @emitter.emit_attrs(:attr_accessor, call_)
        call_.block&.accept(self)
      end
    end
  end
end
