# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      module Utils
        # Utility class that checks if the receiver can't be nil.
        class NilReceiverChecker
          NIL_METHODS = (nil.methods + %i[!]).to_set.freeze

          def initialize(receiver, additional_nil_methods)
            @receiver = receiver
            @additional_nil_methods = additional_nil_methods
            @checked_nodes = {}.compare_by_identity
            @receiver_scope_block = find_receiver_scope_block
          end

          def cant_be_nil?
            sole_condition_of_parent_if?(@receiver) || _cant_be_nil?(@receiver.parent, @receiver)
          end

          private

          # rubocop:disable Metrics
          def _cant_be_nil?(node, receiver)
            return false unless node

            # For some nodes, we check their parent and then some children for these parents.
            # This is added to avoid infinite loops.
            return false if @checked_nodes.key?(node)

            @checked_nodes[node] = true

            case node.type
            when :def, :defs, :class, :module, :sclass
              return false
            when :send
              return non_nil_method?(node.method_name) if node.receiver == receiver

              node.arguments.each do |argument|
                return true if _cant_be_nil?(argument, receiver)
              end

              return true if _cant_be_nil?(node.receiver, receiver)
            when :begin
              return true if _cant_be_nil?(node.children.first, receiver)
            when :if, :case
              return true if _cant_be_nil?(node.condition, receiver)
            when :and, :or
              return true if _cant_be_nil?(node.lhs, receiver)
            when :pair
              if _cant_be_nil?(node.key, receiver) ||
                 _cant_be_nil?(node.value, receiver)
                return true
              end
            when :when
              node.conditions.each do |condition|
                return true if _cant_be_nil?(condition, receiver)
              end
            when :lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn
              return true if _cant_be_nil?(node.expression, receiver)
            end

            # Nodes are compared structurally, so a same-named variable beyond the
            # block that binds the receiver would match even though it is a
            # different variable - stop before crossing that block.
            return false if @receiver_scope_block.equal?(node.parent)

            if sequentially_reached?(node)
              node.left_siblings.reverse_each do |sibling|
                next unless sibling.is_a?(AST::Node)

                return true if _cant_be_nil?(sibling, receiver)
              end
            end

            if node.parent
              _cant_be_nil?(node.parent, receiver)
            else
              false
            end
          end
          # rubocop:enable Metrics

          # The innermost block whose parameters bind the receiver - an explicit
          # or shadowed parameter, `it`, or a numbered parameter. Nodes outside
          # that block's body can only refer to a different, same-named variable.
          def find_receiver_scope_block
            return unless @receiver.lvar_type?

            name = @receiver.children.first
            child = @receiver
            @receiver.each_ancestor do |ancestor|
              return nil if ancestor.type?(:any_def, :sclass)
              return ancestor if rebinds_name?(ancestor, child, name)

              child = ancestor
            end

            nil
          end

          def rebinds_name?(ancestor, child, name)
            ancestor.any_block_type? && ancestor.body.equal?(child) &&
              ancestor.argument_list.any? { |argument| argument.name == name }
          end

          def non_nil_method?(method_name)
            !NIL_METHODS.include?(method_name) && !@additional_nil_methods.include?(method_name)
          end

          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def sole_condition_of_parent_if?(node)
            child = node
            parent = node.parent

            while parent && !parent.equal?(@receiver_scope_block)
              if parent.if_type?
                return true if non_nil_if_condition?(parent, child, node)

                parent = find_top_if(parent) if parent.elsif?
              elsif else_branch?(parent)
                # Find the top `if` for `else`.
                parent = parent.parent
              end

              child = parent
              parent = parent&.parent
            end

            false
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          def non_nil_if_condition?(if_node, child, node)
            return false if if_node.unless?

            condition = if_node.condition
            !child.equal?(condition) && non_nil_condition?(condition, node)
          end

          def non_nil_condition?(condition, node)
            return true if condition == node

            condition.csend_type? && csend_root_receiver(condition) == node
          end

          # Whether control reaches `node` by falling through its left siblings rather than by
          # a non-sequential entry. A `resbody` is entered via an exception, the `ensure` branch
          # runs even after a partway raise, and the `else` arm of an `if/elsif` chain is reached by
          # branching (its `if/case` siblings are walked via parent recursion instead).
          def sequentially_reached?(node)
            return false if node.resbody_type?
            return false if node.parent&.ensure_type? && node.parent.branch.equal?(node)

            !else_branch?(node) || (node.if_type? && !node.elsif?)
          end

          def else_branch?(node)
            node.parent&.if_type? && node.parent.else_branch == node
          end

          def find_top_if(node)
            node = node.parent while node.elsif?

            node
          end

          def csend_root_receiver(node)
            return unless (receiver = node.receiver)

            receiver = receiver.receiver while receiver.call_type? && receiver.receiver

            receiver
          end
        end
      end
    end
  end
end
