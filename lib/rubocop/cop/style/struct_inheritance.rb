# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for inheritance from `Struct.new`. Inheriting from `Struct.new`
      # adds a superfluous level in inheritance tree.
      #
      # @safety
      #   Autocorrection is unsafe because it will change the inheritance
      #   tree (e.g. return value of `Module#ancestors`) of the constant.
      #
      #   It is also unsafe because constants that the class body resolves through its
      #   ancestors (e.g. one provided by an included module) fall out of scope inside
      #   the block.
      #
      # @example
      #   # bad
      #   class Person < Struct.new(:first_name, :last_name)
      #     def age
      #       42
      #     end
      #   end
      #
      #   Person.ancestors
      #   # => [Person, #<Class:0x000000010b4e14a0>, Struct, (...)]
      #
      #   # good
      #   Person = Struct.new(:first_name, :last_name) do
      #     def age
      #       42
      #     end
      #   end
      #
      #   Person.ancestors
      #   # => [Person, Struct, (...)]
      class StructInheritance < Base
        include RangeHelp
        extend AutoCorrector

        MSG = "Don't extend an instance initialized by `Struct.new`. " \
              'Use a block to customize the struct.'
        LEFT_OPERAND_TYPES = %i[and or irange erange match_pattern match_pattern_p].freeze
        ASSIGNMENT_TYPES = %i[lvasgn ivasgn cvasgn gvasgn casgn op_asgn or_asgn and_asgn].freeze
        BODY_TYPES = %i[module class sclass any_def any_block when in_pattern resbody for].freeze

        # When the closing parenthesis of `Struct.new` is on its own line, omitting the
        # parentheses in the same pass leaves a line break before the appended `do`.
        def self.autocorrect_incompatible_with
          [Style::MethodCallWithArgsParentheses]
        end

        def on_class(node)
          return unless struct_constructor?(node.parent_class)
          return if defines_constants?(node.body)

          add_offense(node.parent_class) do |corrector|
            keyword_range =
              range_with_surrounding_space(node.loc.keyword, side: :right, newlines: false)
            corrector.remove(keyword_range)
            corrector.replace(node.loc.operator, '=')

            correct_parent(node.parent_class, corrector)
            parenthesize_left_operand(corrector, node, keyword_range)
          end
        end

        # @!method struct_constructor?(node)
        def_node_matcher :struct_constructor?, <<~PATTERN
          {(send (const {nil? cbase} :Struct) :new ...)
           (block (send (const {nil? cbase} :Struct) :new ...) ...)}
        PATTERN

        private

        # Constants, including nested classes and modules, are scoped to the class when they
        # are defined in a class body, but leak into the enclosing namespace once moved into a
        # `Struct.new` block, so such a class cannot be rewritten as an assignment.
        def defines_constants?(class_body)
          return false unless class_body

          class_body.each_node(:casgn, :class, :module).any?
        end

        def correct_parent(parent, corrector)
          if parent.block_type?
            replace_opening_brace_with_do(corrector, parent) if parent.braces?
            corrector.remove(range_with_surrounding_space(parent.loc.end, newlines: false))
          elsif (range = range_for_empty_class_body(parent))
            corrector.remove(range)
            parenthesize_arguments(corrector, parent) unless statement?(parent.parent)
          else
            parenthesize_arguments(corrector, parent)
            corrector.insert_after(parent, ' do')
          end
        end

        def replace_opening_brace_with_do(corrector, block)
          range = range_with_surrounding_space(block.loc.begin, side: :right, newlines: false)
          return corrector.replace(range, 'do ') if block_content_follows?(range, block)

          corrector.replace(block.loc.begin, 'do')
        end

        def block_content_follows?(opening_range, block)
          return false if opening_range.end_pos == block.loc.end.begin_pos

          opening_range.last_column < opening_range.source_line.length
        end

        def range_for_empty_class_body(struct_new)
          class_node = struct_new.parent
          return if class_node.body

          range = range_between(struct_new.source_range.end_pos, class_node.source_range.end_pos)
          return range if /\A[\s;]*end\z/.match?(range.source)
          return if end_line_kept?(class_node)

          range_by_whole_lines(class_node.loc.end, include_final_newline: true)
        end

        def end_line_kept?(class_node)
          return true if left_operand?(class_node)

          class_node.loc.end.source_line.strip != 'end'
        end

        def left_operand?(class_node)
          parent = class_node.parent
          return false if parent.nil?
          return parent.receiver.equal?(class_node) if parent.call_type?
          return parent.condition.equal?(class_node) if parent.if_type? && parent.ternary?

          LEFT_OPERAND_TYPES.include?(parent.type) && parent.children.first.equal?(class_node)
        end

        def statement?(class_node)
          parent = class_node.parent
          return true if parent.nil? || parent.type?(:begin, :kwbegin, :rescue, :ensure)
          return !parent.condition.equal?(class_node) if conditional_statement?(parent)

          statement_child(parent).equal?(class_node)
        end

        def conditional_statement?(node)
          return true if node.type?(:while, :until)

          node.if_type? && !node.ternary?
        end

        def statement_child(node)
          return node.expression if node.type?(*ASSIGNMENT_TYPES)
          return node.else_branch if node.type?(:case, :case_match)
          return if node.any_def_type? && node.endless?

          node.body if node.type?(*BODY_TYPES)
        end

        def parenthesize_arguments(corrector, struct_new)
          return unless unparenthesized_struct_new?(struct_new)

          arguments_begin = struct_new.first_argument.source_range.begin
          corrector.replace(struct_new.loc.selector.end.join(arguments_begin), '(')
          corrector.insert_after(struct_new.last_argument, ')')
        end

        def unparenthesized_struct_new?(parent)
          parent.send_type? && parent.arguments.any? && !parent.parenthesized?
        end

        def parenthesize_left_operand(corrector, class_node, keyword_range)
          return unless left_operand?(class_node)

          corrector.insert_before(keyword_range, '(')
          corrector.insert_after(class_node.source_range.end, ')')
        end
      end
    end
  end
end
