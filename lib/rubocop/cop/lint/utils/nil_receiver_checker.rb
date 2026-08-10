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
            @receiver_binding_name = binding_name(receiver)
            @receiver_binding_scope = binding_scope(receiver) if @receiver_binding_name
          end

          def cant_be_nil?
            sole_condition_of_parent_if?(@receiver) || _cant_be_nil?(@receiver.parent, @receiver)
          end

          private

          # rubocop:disable-next Metrics
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
              if node.receiver == receiver && same_binding_as_receiver?(node.receiver)
                return non_nil_method?(node.method_name)
              end

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

          def non_nil_method?(method_name)
            !NIL_METHODS.include?(method_name) && !@additional_nil_methods.include?(method_name)
          end

          # rubocop:disable-next Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
          def sole_condition_of_parent_if?(node)
            child = node
            parent = node.parent

            while parent
              if parent.if_type?
                unless parent.unless?
                  condition = parent.condition
                  return true if !child.equal?(condition) && non_nil_condition?(condition, node)
                end

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

          def non_nil_condition?(condition, node)
            return true if condition == node && same_binding_as_receiver?(condition)
            return false unless condition.csend_type?

            root_receiver = csend_root_receiver(condition)

            root_receiver == node && same_binding_as_receiver?(root_receiver)
          end

          # Structurally equal occurrences can be different variables: `it` binds to
          # its innermost block, and a block parameter can shadow an outer variable of
          # the same name. Evidence about such a receiver only holds when both occurrences
          # resolve to the same binding.
          def same_binding_as_receiver?(occurrence)
            return true unless @receiver_binding_name

            binding_scope(occurrence).equal?(@receiver_binding_scope)
          end

          # The name whose binding can differ between structurally equal occurrences:
          # a local variable (block parameters included), or a bare `it` call, which is
          # how `it` parses when the target Ruby version is below 3.4 even though the code
          # may run on 3.4+ where `it` is the implicit block parameter.
          def binding_name(node)
            if node.lvar_type?
              node.children.first
            elsif node.send_type? && !node.receiver && node.method?(:it) && node.arguments.empty?
              :it
            end
          end

          def binding_scope(occurrence)
            node = occurrence

            while (parent = node.parent)
              case parent.type
              when :block, :numblock, :itblock
                # Only the body is inside the block's scope; the send node and the arguments of
                # the block node evaluate in the outer scope.
                return parent if parent.body.equal?(node) && block_binds_name?(parent)
              when :def, :defs, :class, :module, :sclass
                return parent
              end

              node = parent
            end

            nil
          end

          def block_binds_name?(block_node)
            name = @receiver_binding_name

            return true if block_node.argument_list.any? { |argument| argument.name == name }

            name == :it && block_node.arguments.empty?
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
