# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  # `RuboCop::Node` is a subclass of `Parser::AST::Node`. It provides access to
  # parent nodes and an object-oriented way to traverse an AST with the power
  # of `Enumerable`.
  #
  # It has predicate methods for every node type, like this:
  #
  # @example
  #   node.send_type?    # Equivalent to: `node.type == :send`
  #   node.op_asgn_type? # Equivalent to: `node.type == :op_asgn`
  #
  #   # Non-word characters (other than a-zA-Z0-9_) in type names are omitted.
  #   node.defined_type? # Equivalent to: `node.type == :defined?`
  #
  #   # Find the first lvar node under the receiver node.
  #   lvar_node = node.each_descendant.find(&:lvar_type?)
  #
  class Node < Parser::AST::Node # rubocop:disable Metrics/ClassLength
    include RuboCop::Sexp

    COMPARISON_OPERATORS = [:==, :===, :!=, :<=, :>=, :>, :<, :<=>].freeze

    TRUTHY_LITERALS = [:str, :dstr, :xstr, :int, :float, :sym, :dsym, :array,
                       :hash, :regexp, :true, :irange, :erange, :complex,
                       :rational].freeze
    FALSEY_LITERALS = [:false, :nil].freeze
    LITERALS = (TRUTHY_LITERALS + FALSEY_LITERALS).freeze
    BASIC_LITERALS = LITERALS - [:dstr, :xstr, :dsym, :array, :hash, :irange,
                                 :erange].freeze
    MUTABLE_LITERALS = [:str, :dstr, :xstr, :array, :hash].freeze
    IMMUTABLE_LITERALS = (LITERALS - MUTABLE_LITERALS).freeze

    VARIABLES = [:ivar, :gvar, :cvar, :lvar].freeze
    REFERENCES = [:nth_ref, :back_ref].freeze
    KEYWORDS = [:alias, :and, :break, :case, :class, :def, :defs, :defined?,
                :kwbegin, :do, :else, :ensure, :for, :if, :module, :next, :not,
                :or, :postexe, :redo, :rescue, :retry, :return, :self, :super,
                :zsuper, :then, :undef, :until, :when, :while, :yield].freeze
    OPERATOR_KEYWORDS = [:and, :or].freeze
    SPECIAL_KEYWORDS = %w(__FILE__ __LINE__ __ENCODING__).freeze

    # def_matcher can be used to define a pattern-matching method on Node
    class << self
      def def_matcher(method_name, pattern_str)
        compiler = RuboCop::NodePattern::Compiler.new(pattern_str, 'self')
        src = "def #{method_name}(" \
              "#{compiler.emit_param_list});" \
              "#{compiler.emit_method_code};end"

        file, lineno = *caller.first.split(':')
        class_eval(src, file, lineno.to_i)
      end
    end

    # @see http://rubydoc.info/gems/ast/AST/Node:initialize
    def initialize(type, children = [], properties = {})
      @mutable_attributes = {}

      # ::AST::Node#initialize freezes itself.
      super

      # #parent= may be invoked multiple times for a node because there are
      # pending nodes while constructing AST and they are replaced later.
      # For example, `lvar` and `send` type nodes are initially created as an
      # `ident` type node and fixed to the appropriate type later.
      # So, the #parent attribute needs to be mutable.
      each_child_node do |child_node|
        child_node.parent = self
      end
    end

    Parser::Meta::NODE_TYPES.each do |node_type|
      method_name = "#{node_type.to_s.gsub(/\W/, '')}_type?"
      define_method(method_name) do
        type == node_type
      end
    end

    # Returns the parent node, or `nil` if the receiver is a root node.
    #
    # @return [Node, nil] the parent node or `nil`
    def parent
      @mutable_attributes[:parent]
    end

    def parent=(node)
      @mutable_attributes[:parent] = node
    end

    protected :parent=

    # Returns the index of the receiver node in its siblings.
    #
    # @return [Integer] the index of the receiver node in its siblings
    def sibling_index
      parent.children.index { |sibling| sibling.equal?(self) }
    end

    # Calls the given block for each ancestor node from parent to root.
    # If no block is given, an `Enumerator` is returned.
    #
    # @overload each_ancestor
    #   Yield all nodes.
    # @overload each_ancestor(type)
    #   Yield only nodes matching the type.
    #   @param [Symbol] type a node type
    # @overload each_ancestor(type_a, type_b, ...)
    #   Yield only nodes matching any of the types.
    #   @param [Symbol] type_a a node type
    #   @param [Symbol] type_b a node type
    # @overload each_ancestor(types)
    #   Yield only nodes matching any of types in the array.
    #   @param [Array<Symbol>] types an array containing node types
    # @yieldparam [Node] node each ancestor node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_ancestor(*types, &block)
      return to_enum(__method__, *types) unless block_given?

      types.flatten!

      if types.empty?
        visit_ancestors(&block)
      else
        visit_ancestors_with_types(types, &block)
      end

      self
    end

    # Returns an array of ancestor nodes.
    # This is a shorthand for `node.each_ancestor.to_a`.
    #
    # @return [Array<Node>] an array of ancestor nodes
    def ancestors
      each_ancestor.to_a
    end

    # Calls the given block for each child node.
    # If no block is given, an `Enumerator` is returned.
    #
    # Note that this is different from `node.children.each { |child| ... }`
    # which yields all children including non-node elements.
    #
    # @overload each_child_node
    #   Yield all nodes.
    # @overload each_child_node(type)
    #   Yield only nodes matching the type.
    #   @param [Symbol] type a node type
    # @overload each_child_node(type_a, type_b, ...)
    #   Yield only nodes matching any of the types.
    #   @param [Symbol] type_a a node type
    #   @param [Symbol] type_b a node type
    # @overload each_child_node(types)
    #   Yield only nodes matching any of types in the array.
    #   @param [Array<Symbol>] types an array containing node types
    # @yieldparam [Node] node each child node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_child_node(*types)
      return to_enum(__method__, *types) unless block_given?

      types.flatten!

      children.each do |child|
        next unless child.is_a?(Node)
        yield child if types.empty? || types.include?(child.type)
      end

      self
    end

    # Returns an array of child nodes.
    # This is a shorthand for `node.each_child_node.to_a`.
    #
    # @return [Array<Node>] an array of child nodes
    def child_nodes
      each_child_node.to_a
    end

    # Calls the given block for each descendant node with depth first order.
    # If no block is given, an `Enumerator` is returned.
    #
    # @overload each_descendant
    #   Yield all nodes.
    # @overload each_descendant(type)
    #   Yield only nodes matching the type.
    #   @param [Symbol] type a node type
    # @overload each_descendant(type_a, type_b, ...)
    #   Yield only nodes matching any of the types.
    #   @param [Symbol] type_a a node type
    #   @param [Symbol] type_b a node type
    # @overload each_descendant(types)
    #   Yield only nodes matching any of types in the array.
    #   @param [Array<Symbol>] types an array containing node types
    # @yieldparam [Node] node each descendant node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_descendant(*types, &block)
      return to_enum(__method__, *types) unless block_given?

      types.flatten!

      if types.empty?
        visit_descendants(&block)
      else
        visit_descendants_with_types(types, &block)
      end

      self
    end

    # Returns an array of descendant nodes.
    # This is a shorthand for `node.each_descendant.to_a`.
    #
    # @return [Array<Node>] an array of descendant nodes
    def descendants
      each_descendant.to_a
    end

    # Calls the given block for the receiver and each descendant node in
    # depth-first order.
    # If no block is given, an `Enumerator` is returned.
    #
    # This method would be useful when you treat the receiver node as the root
    # of a tree and want to iterate over all nodes in the tree.
    #
    # @overload each_node
    #   Yield all nodes.
    # @overload each_node(type)
    #   Yield only nodes matching the type.
    #   @param [Symbol] type a node type
    # @overload each_node(type_a, type_b, ...)
    #   Yield only nodes matching any of the types.
    #   @param [Symbol] type_a a node type
    #   @param [Symbol] type_b a node type
    # @overload each_node(types)
    #   Yield only nodes matching any of types in the array.
    #   @param [Array<Symbol>] types an array containing node types
    # @yieldparam [Node] node each node
    # @return [self] if a block is given
    # @return [Enumerator] if no block is given
    def each_node(*types, &block)
      return to_enum(__method__, *types) unless block_given?

      types.flatten!

      yield self if types.empty? || types.include?(type)

      if types.empty?
        visit_descendants(&block)
      else
        visit_descendants_with_types(types, &block)
      end

      self
    end

    def source
      loc.expression.source
    end

    def source_range
      loc.expression
    end

    ## Destructuring

    def_matcher :receiver,    '{(send $_ ...) (block (send $_ ...) ...)}'
    def_matcher :method_name, '{(send _ $_ ...) (block (send _ $_ ...) ...)}'
    def_matcher :method_args, '{(send _ _ $...) (block (send _ _ $...) ...)}'
    # Note: for masgn, #asgn_rhs will be an array node
    def_matcher :asgn_rhs, '[assignment? (... $_)]'
    def_matcher :str_content, '(str $_)'

    def const_name
      return unless const_type?
      namespace, name = *self
      if namespace && !namespace.cbase_type?
        "#{namespace.const_name}::#{name}"
      else
        name.to_s
      end
    end

    def_matcher :defined_module0, <<-PATTERN
      {(class (const $_ $_) ...)
       (module (const $_ $_) ...)
       (casgn $_ $_        (send (const nil {:Class :Module}) :new ...))
       (casgn $_ $_ (block (send (const nil {:Class :Module}) :new ...) ...))}
    PATTERN
    private :defined_module0

    def defined_module
      namespace, name = *defined_module0
      s(:const, namespace, name) if name
    end

    def defined_module_name
      (const = defined_module) && const.const_name
    end

    ## Searching the AST

    def parent_module_name
      # what class or module is this method/constant/etc definition in?
      # returns nil if answer cannot be determined
      ancestors = each_ancestor(:class, :module, :sclass, :casgn, :block)
      result    = ancestors.map do |ancestor|
        case ancestor.type
        when :class, :module, :casgn
          # TODO: if constant name has cbase (leading ::), then we don't need
          # to keep traversing up through nested classes/modules
          ancestor.defined_module_name
        when :sclass
          obj = ancestor.children[0]
          # TODO: look for constant definition and see if it is nested
          # inside a class or module
          return "#<Class:#{obj.const_name}>" if obj.const_type?
          return "#<Class:#{ancestor.parent_module_name}>" if obj.self_type?
          return nil
        else # block
          # Known DSL methods which eval body inside an anonymous class/module
          return nil if [:describe, :it].include?(ancestor.method_name) &&
                        ancestor.receiver.nil?
          if ancestor.method_name == :class_eval && ancestor.receiver
            return nil unless ancestor.receiver.const_type?
            ancestor.receiver.const_name
          end
        end
      end.compact.reverse.join('::')
      result.empty? ? 'Object' : result
    end

    ## Predicates

    def multiline?
      expr = loc.expression
      expr && (expr.first_line != expr.last_line)
    end

    def single_line?
      !multiline?
    end

    def asgn_method_call?
      !COMPARISON_OPERATORS.include?(method_name) &&
        method_name.to_s.end_with?('=')
    end

    def_matcher :equals_asgn?, '{lvasgn ivasgn cvasgn gvasgn casgn masgn}'
    def_matcher :shorthand_asgn?, '{op_asgn or_asgn and_asgn}'
    def_matcher :assignment?, '{equals_asgn? shorthand_asgn? asgn_method_call?}'

    def literal?
      LITERALS.include?(type)
    end

    def basic_literal?
      BASIC_LITERALS.include?(type)
    end

    def truthy_literal?
      TRUTHY_LITERALS.include?(type)
    end

    def falsey_literal?
      FALSEY_LITERALS.include?(type)
    end

    def mutable_literal?
      MUTABLE_LITERALS.include?(type)
    end

    def immutable_literal?
      IMMUTABLE_LITERALS.include?(type)
    end

    def variable?
      VARIABLES.include?(type)
    end

    def reference?
      REFERENCES.include?(type)
    end

    def keyword?
      return true if special_keyword? || keyword_not?
      return false unless KEYWORDS.include?(type)

      !OPERATOR_KEYWORDS.include?(type) || loc.operator.is?(type.to_s)
    end

    def special_keyword?
      SPECIAL_KEYWORDS.include?(source)
    end

    def keyword_not?
      _receiver, method_name, *args = *self
      args.empty? && method_name == :! && loc.selector.is?('not'.freeze)
    end

    def_matcher :command?, '(send nil %1 ...)'
    def_matcher :lambda?,  '(block (send nil :lambda) ...)'
    def_matcher :proc?, <<-PATTERN
      {(block (send nil :proc) ...)
       (block (send (const nil :Proc) :new) ...)
       (send (const nil :Proc) :new)}
    PATTERN
    def_matcher :lambda_or_proc?, '{lambda? proc?}'

    def_matcher :class_constructor?, <<-PATTERN
      {       (send (const nil {:Class :Module}) :new ...)
       (block (send (const nil {:Class :Module}) :new ...) ...)}
    PATTERN

    def_matcher :module_definition?, <<-PATTERN
      {class module (casgn _ _ class_constructor?)}
    PATTERN

    # Some expressions are evaluated for their value, some for their side
    # effects, and some for both
    # If we know that an expression is useful only for its side effects, that
    # means we can transform it in ways which preserve the side effects, but
    # change the return value
    # So, does the return value of this node matter? If we changed it to
    # `(...; nil)`, might that affect anything?
    #
    def value_used?
      # Be conservative and return true if we're not sure
      return false if parent.nil?
      index = parent.children.index { |child| child.equal?(self) }

      case parent.type
      when :array, :block, :defined?, :dstr, :dsym, :eflipflop, :erange, :float,
           :hash, :iflipflop, :irange, :not, :pair, :regexp, :str, :sym, :when,
           :xstr
        parent.value_used?
      when :begin, :kwbegin
        # the last child node determines the value of the parent
        index == parent.children.size - 1 ? parent.value_used? : false
      when :for
        # `for var in enum; body; end`
        # (for <var> <enum> <body>)
        index == 2 ? parent.value_used? : true
      when :case, :if
        # (case <condition> <when...>)
        # (if <condition> <truebranch> <falsebranch>)
        index == 0 ? true : parent.value_used?
      when :while, :until, :while_post, :until_post
        # (while <condition> <body>) -> always evaluates to `nil`
        index == 0
      else
        true
      end
    end

    # Some expressions are evaluated for their value, some for their side
    # effects, and some for both
    # If we know that expressions are useful only for their return values, and
    # have no side effects, that means we can reorder them, change the number
    # of times they are evaluated, or replace them with other expressions which
    # are equivalent in value
    # So, is evaluation of this node free of side effects?
    #
    def pure?
      # Be conservative and return false if we're not sure
      case type
      when :__FILE__, :__LINE__, :const, :cvar, :defined?, :false, :float,
           :gvar, :int, :ivar, :lvar, :nil, :str, :sym, :true
        true
      when :and, :array, :begin, :case, :dstr, :dsym, :eflipflop, :ensure,
           :erange, :for, :hash, :if, :iflipflop, :irange, :kwbegin, :not, :or,
           :pair, :regexp, :until, :until_post, :when, :while, :while_post
        child_nodes.all?(&:pure?)
      else
        false
      end
    end

    protected

    def visit_descendants(&block)
      children.each do |child|
        next unless child.is_a?(Node)
        yield child
        child.visit_descendants(&block)
      end
    end

    def visit_descendants_with_types(types, &block)
      children.each do |child|
        next unless child.is_a?(Node)
        yield child if types.include?(child.type)
        child.visit_descendants_with_types(types, &block)
      end
    end

    private

    def visit_ancestors
      last_node = self

      while (current_node = last_node.parent)
        yield current_node
        last_node = current_node
      end
    end

    def visit_ancestors_with_types(types)
      last_node = self

      while (current_node = last_node.parent)
        yield current_node if types.include?(current_node.type)
        last_node = current_node
      end
    end
  end
end
