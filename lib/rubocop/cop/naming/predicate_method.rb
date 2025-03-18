# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Checks that predicate methods end with `?` and non-predicate methods do not.
      #
      # The names of predicate methods (methods that return a boolean value) should end
      # in a question mark. Methods that don’t return a boolean, shouldn’t
      # end in a question mark.
      #
      # The cop assesses a predicate method as one that returns boolean values. Likewise,
      # a method that only returns literal values is assessed as non-predicate. The cop does
      # not make an assessment if the return type is unknown (method calls, variables, etc.).
      #
      # NOTE: Operator methods (`def ==`, etc.) are ignored.
      #
      # By default, the cop runs in `conservative` mode, which allows a method to be named
      # with a question mark as long as at least one return value is boolean. In `aggressive`
      # mode, methods with a question mark will register an offense if any known non-boolean
      # return values are detected.
      #
      # The cop also has `AllowedMethods` configuration in order to prevent the cop from
      # registering an offense from a method name that does not confirm to the naming
      # guidelines. By default, `call` is allowed.
      #
      # @example Mode: conservative (default)
      #   # bad
      #   def foo
      #     bar == baz
      #   end
      #
      #   # good
      #   def foo?
      #     bar == baz
      #   end
      #
      #   # bad
      #   def foo?
      #     5
      #   end
      #
      #   # good
      #   def foo
      #     5
      #   end
      #
      #   # good - operator method
      #   def ==(other)
      #     hash == other.hash
      #   end
      #
      #   # good - at least one return value is boolean
      #   def foo?
      #     return unless bar?
      #     true
      #   end
      #
      #   # ok - return type is not known
      #   def foo?
      #     bar
      #   end
      #
      #   # ok - return type is not known
      #   def foo
      #     bar?
      #   end
      #
      # @example Mode: aggressive
      #   # bad - the method returns nil in some cases
      #   def foo?
      #     return unless bar?
      #     true
      #   end
      #
      class PredicateMethod < Base
        include AllowedMethods

        MSG_PREDICATE = 'Predicate method names should end with `?`.'
        MSG_NON_PREDICATE = 'Non-predicate method names should not end with `?`.'

        def on_def(node)
          return if allowed?(node)

          return_values = return_values(node.body)
          return if acceptable?(return_values)

          if node.predicate_method? && potential_non_predicate?(return_values)
            add_offense(node.loc.name, message: MSG_NON_PREDICATE)
          elsif !node.predicate_method? && all_return_values_boolean?(return_values)
            add_offense(node.loc.name, message: MSG_PREDICATE)
          end
        end
        alias on_defs on_def

        private

        def allowed?(node)
          allowed_method?(node.method_name) ||
            node.operator_method? ||
            node.body.nil?
        end

        def acceptable?(return_values)
          # In `conservative` mode, if the method returns `super`, `zsuper`, or a
          # non-comparison method call, the method name is acceptable.
          return false unless conservative?

          return_values.any? do |value|
            value.type?(:super, :zsuper) || non_comparison_call?(value)
          end
        end

        def non_comparison_call?(value)
          value.call_type? && !value.comparison_method?
        end

        def return_values(node)
          # Collect all the (implicit and explicit) return values of a node
          return_values = Set.new(node.begin_type? ? [] : [extract_return_value(node)])

          node.each_descendant(:return) do |return_node|
            return_values << extract_return_value(return_node)
          end

          last_value = last_value(node)
          return_values << last_value if last_value

          process_return_values(return_values)
        end

        def all_return_values_boolean?(return_values)
          values = return_values.reject { |value| value.type?(:super, :zsuper) }
          return false if values.empty?

          values.all? { |value| boolean_return?(value) }
        end

        def boolean_return?(value)
          value.boolean_type? || (value.call_type? && value.comparison_method?)
        end

        def potential_non_predicate?(return_values)
          # Assumes a method to be non-predicate if all return values are non-boolean literals.
          #
          # In `Mode: conservative`, if any of the return values is a boolean,
          # the method name is acceptable.
          # In `Mode: aggressive`, all return values must be booleans for a predicate
          # method, or else an offense will be registered.
          return false if conservative? && return_values.any? { |value| boolean_return?(value) }

          return_values.any? do |value|
            value.literal? && !value.boolean_type?
          end
        end

        def extract_return_value(node)
          return node unless node.return_type?

          # `return` without a value is a `nil` return.
          return s(:nil) if node.arguments.empty?

          # When there's a multiple return, it cannot be a predicate
          # so just return an `array` sexp for simplicity.
          return s(:array) unless node.arguments.one?

          node.first_argument
        end

        def last_value(node)
          value = node.begin_type? ? node.children.last : node
          value.return_type? ? extract_return_value(value) : value
        end

        def process_return_values(return_values)
          return_values.flat_map do |value|
            if value.conditional?
              process_return_values(extract_conditional_branches(value))
            elsif and_or?(value)
              process_return_values(extract_and_or_clauses(value))
            else
              value
            end
          end
        end

        def and_or?(node)
          node.type?(:and, :or)
        end

        def extract_and_or_clauses(node)
          # Recursively traverse an `and` or `or` node to collect all clauses within
          return node unless and_or?(node)

          [extract_and_or_clauses(node.lhs), extract_and_or_clauses(node.rhs)].flatten
        end

        def extract_conditional_branches(node)
          return node unless node.conditional?

          if node.type?(:while, :until)
            # If there is no body, act as implicit `nil`.
            node.body ? [last_value(node.body)] : [s(:nil)]
          else
            # Branches with no value act as an implicit `nil`.
            node.branches.filter_map { |branch| branch ? last_value(branch) : s(:nil) }
          end
        end

        def conservative?
          cop_config.fetch('Mode', :conservative).to_sym == :conservative
        end
      end
    end
  end
end
