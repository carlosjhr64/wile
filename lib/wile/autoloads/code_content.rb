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

  # CodeContent class generates code content for the Wile framework.
  # :reek:InstanceVariableAssumption
  # :reek:TooManyInstanceVariables :reek:TooManyMethods
  # rubocop:disable-next Metrics/ClassLength
  class CodeContent < Prism::Visitor
    def self.ast(fnm) = Prism::Translation::Parser.parse_file(fnm).inspect.lines

    def self.generate(filename, &) = new.generate(filename, &)

    def generate(fnm, &blk)
      vset(blk, nil, '#', Set.new, [])
      Prism.parse_file(fnm).value.accept(self)
    ensure
      vset
    end

    def visit_def_node(node_, receiver = node_.receiver)
      return super(node_) if receiver && !receiver.is_a?(Prism::SelfNode) &&
                             !CONST_NODES.include?(receiver.class)

      @dot = '.' if receiver || @scope.last == '.'
      def_body(node_.name_loc.slice, def_scope(receiver)) { super(node_) }
    end

    def visit_module_node(node_)
      with_scope(node_.constant_path.slice.delete_prefix('::')) { super }
    end
    alias visit_class_node visit_module_node

    def visit_singleton_class_node(_node)
      with_scope('.') { super }
    end

    def visit_call_node(node_)
      receiver = node_.receiver
      name = node_.name
      return if !receiver && special_call?(node_, name)

      handle_call(receiver, name) if CALL_NAME.match?(name)
      super
    end

    def visit_lambda_node(node_)
      emit_call("#{@dot}lambda")
      super
    end

    def visit_constant_path_write_node(node_)
      emit_casgn(node_.target.slice.delete_prefix('::'), node_)
    end

    def visit_constant_write_node(node_)
      emit_casgn([scope_str, node_.name].reject(&:empty?).join('::'), node_)
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

    def special_call?(node_, name)
      return visit_refine(node_) || true if name == :refine && node_.block
      return emit_attrs(name, node_) || true if ATTR_SUFFIXES.key?(name)

      false
    end

    def emit_attrs(macro, node_)
      prefix = "##{macro} #{scope_str}#{@scope.last == '.' ? '.' : '#'}"
      syms = (node_.arguments&.arguments || []).grep(Prism::SymbolNode)
      syms.product(ATTR_SUFFIXES[macro]).each do |sym, sfx|
        emit_call("#{prefix}#{sym.unescaped}#{sfx}")
      end
    end

    def visit_refine(node_, target = node_.arguments.arguments.first.slice)
      scopes = target.delete_prefix('::').sub('.singleton_class', ' .').split
      with_scope(*scopes) { node_.block.accept(self) }
    end

    def scope_str = @scope.reject { it == '.' }.join('::')

    def def_scope(receiver)
      return scope_str unless CONST_NODES.include?(receiver&.class)

      named = receiver.slice.delete_prefix('::')
      return scope_str if scope_str.split('::').last == named
      return named if scope_str.empty? || named.start_with?(scope_str)

      "#{scope_str}::#{named}"
    end

    def def_body(name, target = scope_str)
      @dependencies = Set.new
      @block["def #{target}#{@dot}#{name}"]
      yield
    ensure
      @dot = '#'
      @dependencies = nil
      @block['end']
    end

    def emit_casgn(full, node_, val = node_.value)
      type = casgn_type(val)
      @block["casgn #{full} #{type}"]
      emit_struct(full, val) if type == 'Struct'
    end

    # :reek:UtilityFunction
    def casgn_type(val)
      while val.is_a?(Prism::CallNode)
        return val.name unless (receiver = val.receiver)

        val = receiver
      end
      CASGN_TYPES[val.type] || val.slice.delete_prefix('::')
    end

    def emit_struct(full, call_)
      return unless call_.is_a?(Prism::CallNode) && call_.name == :new

      with_scope(full.delete_prefix("#{scope_str}::")) do
        emit_attrs(:attr_accessor, call_)
        call_.block&.accept(self)
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

    def handle_call(receiver, name, slice = receiver&.slice)
      if !receiver
        emit_call("#{@dot}#{name}")
      elsif CONST_NODES.include?(receiver.class)
        emit_call("#{slice.delete_prefix('::')}.#{name}")
      elsif slice == 'new'
        emit_call("#{@dot}new")
        emit_call("##{name}")
      else
        emit_call("#{slice[DUCK_NAME] || '*'}##{name}")
      end
    end
  end
end
