# frozen_string_literal: true

module RuboCop
  module AST
    # `RuboCop::AST::Node` is a subclass of `Parser::AST::Node`. It provides
    # access to parent nodes and an object-oriented way to traverse an AST with
    # the power of `Enumerable`.
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
      include RuboCop::AST::Sexp
      extend NodePattern::Macros

      # <=> isn't included here, because it doesn't return a boolean.
      COMPARISON_OPERATORS = %i[== === != <= >= > <].freeze

      TRUTHY_LITERALS = %i[str dstr xstr int float sym dsym array
                           hash regexp true irange erange complex
                           rational regopt].freeze
      FALSEY_LITERALS = %i[false nil].freeze
      LITERALS = (TRUTHY_LITERALS + FALSEY_LITERALS).freeze
      COMPOSITE_LITERALS = %i[dstr xstr dsym array hash irange
                              erange regexp].freeze
      BASIC_LITERALS = (LITERALS - COMPOSITE_LITERALS).freeze
      MUTABLE_LITERALS = %i[str dstr xstr array hash].freeze
      IMMUTABLE_LITERALS = (LITERALS - MUTABLE_LITERALS).freeze

      VARIABLES = %i[ivar gvar cvar lvar].freeze
      REFERENCES = %i[nth_ref back_ref].freeze
      KEYWORDS = %i[alias and break case class def defs defined?
                    kwbegin do else ensure for if module next
                    not or postexe redo rescue retry return self
                    super zsuper then undef until when while
                    yield].freeze
      OPERATOR_KEYWORDS = %i[and or].freeze
      SPECIAL_KEYWORDS = %w[__FILE__ __LINE__ __ENCODING__].freeze

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
          child_node.parent = self unless child_node.complete?
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

      def complete!
        @mutable_attributes.freeze
        each_child_node(&:complete!)
      end

      def complete?
        @mutable_attributes.frozen?
      end

      protected :parent=

      # Override `AST::Node#updated` so that `AST::Processor` does not try to
      # mutate our ASTs. Since we keep references from children to parents and
      # not just the other way around, we cannot update an AST and share
      # identical subtrees. Rather, the entire AST must be copied any time any
      # part of it is changed.
      def updated(type = nil, children = nil, properties = {})
        properties[:location] ||= @location
        self.class.new(type || @type, children || @children, properties)
      end

      # Returns the index of the receiver node in its siblings. (Sibling index
      # uses zero based numbering.)
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

        visit_ancestors(types, &block)

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

        visit_descendants(types, &block)

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

        yield self if types.empty? || types.include?(type)

        visit_descendants(types, &block)

        self
      end

      def source
        loc.expression.source
      end

      def source_range
        loc.expression
      end

      ## Destructuring

      def_node_matcher :receiver, <<-PATTERN
        {(send $_ ...) (block (send $_ ...) ...)}
      PATTERN

      def_node_matcher :method_name, <<-PATTERN
        {(send _ $_ ...) (block (send _ $_ ...) ...)}
      PATTERN

      # Note: for masgn, #asgn_rhs will be an array node
      def_node_matcher :asgn_rhs, '[assignment? (... $_)]'
      def_node_matcher :str_content, '(str $_)'

      def const_name
        return unless const_type?
        namespace, name = *self
        if namespace && !namespace.cbase_type?
          "#{namespace.const_name}::#{name}"
        else
          name.to_s
        end
      end

      def_node_matcher :defined_module0, <<-PATTERN
        {(class (const $_ $_) ...)
         (module (const $_ $_) ...)
         (casgn $_ $_        (send (const nil? {:Class :Module}) :new ...))
         (casgn $_ $_ (block (send (const nil? {:Class :Module}) :new ...) ...))}
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
          parent_module_name_part(ancestor) { |full_name| return full_name }
        end.compact.reverse.join('::')
        result.empty? ? 'Object' : result
      end

      ## Predicates

      def multiline?
        line_count > 1
      end

      def single_line?
        line_count == 1
      end

      def line_count
        return 0 unless source_range
        source_range.last_line - source_range.first_line + 1
      end

      def asgn_method_call?
        !COMPARISON_OPERATORS.include?(method_name) &&
          method_name.to_s.end_with?('='.freeze)
      end

      def_node_matcher :equals_asgn?, <<-PATTERN
        {lvasgn ivasgn cvasgn gvasgn casgn masgn}
      PATTERN

      def_node_matcher :shorthand_asgn?, '{op_asgn or_asgn and_asgn}'

      def_node_matcher :assignment?, <<-PATTERN
        {equals_asgn? shorthand_asgn? asgn_method_call?}
      PATTERN

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

      %i[literal basic_literal].each do |kind|
        recursive_kind = :"recursive_#{kind}?"
        kind_filter = :"#{kind}?"
        define_method(recursive_kind) do
          case type
          when :send
            receiver, method_name, *args = *self
            [*COMPARISON_OPERATORS, :!, :<=>].include?(method_name) &&
              receiver.send(recursive_kind) &&
              args.all?(&recursive_kind)
          when :begin, :pair, *OPERATOR_KEYWORDS, *COMPOSITE_LITERALS
            children.all?(&recursive_kind)
          else
            send(kind_filter)
          end
        end
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

      def operator_keyword?
        OPERATOR_KEYWORDS.include?(type)
      end

      def keyword_not?
        _receiver, method_name, *args = *self
        args.empty? && method_name == :! && loc.selector.is?('not'.freeze)
      end

      def keyword_bang?
        _receiver, method_name, *args = *self
        args.empty? && method_name == :! && loc.selector.is?('!'.freeze)
      end

      def unary_operation?
        return false unless loc.respond_to?(:selector) && loc.selector
        Cop::Util.operator?(loc.selector.source.to_sym) &&
          source_range.begin_pos == loc.selector.begin_pos
      end

      def binary_operation?
        return false unless loc.respond_to?(:selector) && loc.selector
        Cop::Util.operator?(method_name) &&
          source_range.begin_pos != loc.selector.begin_pos
      end

      def chained?
        return false unless argument?

        receiver, _method_name, *_args = *parent
        equal?(receiver)
      end

      def argument?
        parent && parent.send_type?
      end

      def numeric_type?
        int_type? || float_type?
      end

      def_node_matcher :guard_clause?, <<-PATTERN
        [{(send nil? {:raise :fail} ...) return break next} single_line?]
      PATTERN

      def_node_matcher :proc?, <<-PATTERN
        {(block (send nil? :proc) ...)
         (block (send (const nil? :Proc) :new) ...)
         (send (const nil? :Proc) :new)}
      PATTERN

      def_node_matcher :lambda?, '(block (send nil? :lambda) ...)'
      def_node_matcher :lambda_or_proc?, '{lambda? proc?}'

      def_node_matcher :class_constructor?, <<-PATTERN
        {       (send (const nil? {:Class :Module}) :new ...)
         (block (send (const nil? {:Class :Module}) :new ...) ...)}
      PATTERN

      def_node_matcher :module_definition?, <<-PATTERN
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
      # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      def value_used?
        # Be conservative and return true if we're not sure.
        return false if parent.nil?

        case parent.type
        when :array, :defined?, :dstr, :dsym, :eflipflop, :erange, :float,
             :hash, :iflipflop, :irange, :not, :pair, :regexp, :str, :sym,
             :when, :xstr
          parent.value_used?
        when :begin, :kwbegin
          begin_value_used?
        when :for
          for_value_used?
        when :case, :if
          case_if_value_used?
        when :while, :until, :while_post, :until_post
          while_until_value_used?
        else
          true
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

      # Some expressions are evaluated for their value, some for their side
      # effects, and some for both.
      # If we know that expressions are useful only for their return values,
      # and have no side effects, that means we can reorder them, change the
      # number of times they are evaluated, or replace them with other
      # expressions which are equivalent in value.
      # So, is evaluation of this node free of side effects?
      #
      def pure?
        # Be conservative and return false if we're not sure
        case type
        when :__FILE__, :__LINE__, :const, :cvar, :defined?, :false, :float,
             :gvar, :int, :ivar, :lvar, :nil, :str, :sym, :true, :regopt
          true
        when :and, :array, :begin, :case, :dstr, :dsym, :eflipflop, :ensure,
             :erange, :for, :hash, :if, :iflipflop, :irange, :kwbegin, :not,
             :or, :pair, :regexp, :until, :until_post, :when, :while,
             :while_post
          child_nodes.all?(&:pure?)
        else
          false
        end
      end

      protected

      def visit_descendants(types, &block)
        each_child_node do |child|
          yield child if types.empty? || types.include?(child.type)
          child.visit_descendants(types, &block)
        end
      end

      private

      def visit_ancestors(types)
        last_node = self

        while (current_node = last_node.parent)
          yield current_node if types.empty? ||
                                types.include?(current_node.type)
          last_node = current_node
        end
      end

      def begin_value_used?
        # the last child node determines the value of the parent
        sibling_index == parent.children.size - 1 ? parent.value_used? : false
      end

      def for_value_used?
        # `for var in enum; body; end`
        # (for <var> <enum> <body>)
        sibling_index == 2 ? parent.value_used? : true
      end

      def case_if_value_used?
        # (case <condition> <when...>)
        # (if <condition> <truebranch> <falsebranch>)
        sibling_index.zero? ? true : parent.value_used?
      end

      def while_until_value_used?
        # (while <condition> <body>) -> always evaluates to `nil`
        sibling_index.zero?
      end

      def parent_module_name_part(node)
        case node.type
        when :class, :module, :casgn
          # TODO: if constant name has cbase (leading ::), then we don't need
          # to keep traversing up through nested classes/modules
          node.defined_module_name
        when :sclass
          yield parent_module_name_for_sclass(node)
        else # block
          parent_module_name_for_block(node) { yield nil }
        end
      end

      def parent_module_name_for_sclass(sclass_node)
        # TODO: look for constant definition and see if it is nested
        # inside a class or module
        subject = sclass_node.children[0]

        if subject.const_type?
          "#<Class:#{subject.const_name}>"
        elsif subject.self_type?
          "#<Class:#{sclass_node.parent_module_name}>"
        end
      end

      def parent_module_name_for_block(ancestor)
        if ancestor.method_name == :class_eval
          # `class_eval` with no receiver applies to whatever module or class
          # we are currently in
          return unless (receiver = ancestor.receiver)
          yield unless receiver.const_type?
          receiver.const_name
        elsif !new_class_or_module_block?(ancestor)
          yield
        end
      end

      def_node_matcher :new_class_or_module_block?, <<-PATTERN
        ^(casgn _ _ (block (send (const _ {:Class :Module}) :new) ...))
      PATTERN
    end
  end
end
