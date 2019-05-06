# frozen_string_literal: true

module RuboCop
  module AST
    # Common predicates for nodes that reference method identifiers:
    # `send`, `csend`, `def`, `defs`, `super`, `zsuper`
    #
    # @note this mixin expects `#method_name` and `#receiver` to be implemented
    module MethodIdentifierPredicates
      ENUMERATOR_METHODS = %i[collect collect_concat detect downto each
                              find find_all find_index inject loop map!
                              map reduce reject reject! reverse_each select
                              select! times upto].freeze

      # http://phrogz.net/programmingruby/language.html#table_18.4
      OPERATOR_METHODS = %i[| ^ & <=> == === =~ > >= < <= << >> + - * /
                            % ** ~ +@ -@ !@ ~@ [] []= ! != !~ `].freeze

      # Checks whether the method name matches the argument.
      #
      # @param [Symbol, String] name the method name to check for
      # @return [Boolean] whether the method name matches the argument
      def method?(name)
        method_name == name.to_sym
      end

      # Checks whether the method is an operator method.
      #
      # @return [Boolean] whether the method is an operator
      def operator_method?
        OPERATOR_METHODS.include?(method_name)
      end

      # Checks whether the method is a comparison method.
      #
      # @return [Boolean] whether the method is a comparison
      def comparison_method?
        Node::COMPARISON_OPERATORS.include?(method_name)
      end

      # Checks whether the method is an assignment method.
      #
      # @return [Boolean] whether the method is an assignment
      def assignment_method?
        !comparison_method? && method_name.to_s.end_with?('=')
      end

      # Checks whether the method is an enumerator method.
      #
      # @return [Boolean] whether the method is an enumerator
      def enumerator_method?
        ENUMERATOR_METHODS.include?(method_name) ||
          method_name.to_s.start_with?('each_')
      end

      # Checks whether the method is a predicate method.
      #
      # @return [Boolean] whether the method is a predicate method
      def predicate_method?
        method_name.to_s.end_with?('?')
      end

      # Checks whether the method is a bang method.
      #
      # @return [Boolean] whether the method is a bang method
      def bang_method?
        method_name.to_s.end_with?('!')
      end

      # Checks whether the method is a camel case method,
      # e.g. `Integer()`.
      #
      # @return [Boolean] whether the method is a camel case method
      def camel_case_method?
        method_name.to_s =~ /\A[A-Z]/
      end

      # Checks whether the *explicit* receiver of this node is `self`.
      #
      # @return [Boolean] whether the receiver of this node is `self`
      def self_receiver?
        receiver&.self_type?
      end

      # Checks whether the *explicit* receiver of node is a `const` node.
      #
      # @return [Boolean] whether the receiver of this node is a `const` node
      def const_receiver?
        receiver&.const_type?
      end

      # Checks whether this is a negation method, i.e. `!` or keyword `not`.
      #
      # @return [Boolean] whether this method is a negation method
      def negation_method?
        receiver && method_name == :!
      end

      # Checks whether this is a prefix not method, e.g. `not foo`.
      #
      # @return [Boolean] whether this method is a prefix not
      def prefix_not?
        negation_method? && loc.selector.is?('not')
      end

      # Checks whether this is a prefix bang method, e.g. `!foo`.
      #
      # @return [Boolean] whether this method is a prefix bang
      def prefix_bang?
        negation_method? && loc.selector.is?('!')
      end
    end
  end
end
