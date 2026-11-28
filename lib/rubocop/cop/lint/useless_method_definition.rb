# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for useless method definitions, specifically: empty constructors
      # and methods just delegating to `super`.
      #
      # @safety
      #   This cop is unsafe as it can register false positives for cases when an empty
      #   constructor just overrides the parent constructor, which is bad anyway.
      #
      # @example
      #   # bad
      #   def initialize
      #     super
      #   end
      #
      #   def method
      #     super
      #   end
      #
      #   # good - with default arguments
      #   def initialize(x = Object.new)
      #     super
      #   end
      #
      #   # good
      #   def initialize
      #     super
      #     initialize_internals
      #   end
      #
      #   def method(*args)
      #     super(:extra_arg, *args)
      #   end
      #
      class UselessMethodDefinition < Base
        extend AutoCorrector

        MSG = 'Useless method definition detected.'

        def on_def(node)
          return if use_rest_or_optional_args?(node)
          return unless delegating?(node.body, node)

          statement = visibility_declaration(node) || node
          return unless removable_statement?(statement)

          add_offense(node) { |corrector| corrector.remove(statement) }
        end
        alias on_defs on_def

        private

        def visibility_declaration(node)
          parent = node.parent
          parent if parent&.send_type? && parent.non_bare_access_modifier? && parent.arguments.one?
        end

        def removable_statement?(node)
          parent = node.parent
          return true unless parent

          return true if definition_block_body?(node, parent)

          if parent.type?(:begin, :kwbegin)
            return true unless parent.children.last.equal?(node)
          elsif !statement_body?(parent, node)
            return false
          end

          removable_statement?(parent)
        end

        def definition_block_body?(node, parent)
          return false unless parent.any_block_type? && parent.body.equal?(node)

          return true if parent.class_constructor?

          parent.receiver.nil? && %i[included class_methods].include?(parent.method_name)
        end

        def statement_body?(parent, node)
          if parent.if_type?
            !parent.ternary? && !parent.modifier_form? && !parent.condition.equal?(node)
          else
            parent.type?(:class, :module, :sclass) && parent.body.equal?(node)
          end
        end

        def use_rest_or_optional_args?(node)
          node.arguments.any? { |arg| arg.type?(:restarg, :optarg, :kwoptarg, :kwrestarg) }
        end

        def delegating?(node, def_node)
          if node&.zsuper_type?
            true
          elsif node&.super_type?
            node.arguments.map(&:source) == def_node.arguments.map(&:source)
          else
            false
          end
        end
      end
    end
  end
end
