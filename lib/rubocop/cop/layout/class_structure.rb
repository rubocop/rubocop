# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks if the code style follows the `ExpectedOrder` configuration:
      #
      # `Categories` allows us to map macro names into a category.
      #
      # Consider an example of code style that covers the following order:
      #
      # * Module inclusion (`include`, `prepend`, `extend`)
      # * Constants
      # * Associations (`has_one`, `has_many`)
      # * Public attribute macros (`attr_accessor`, `attr_writer`, `attr_reader`)
      # * Other macros (`validates`, `validate`)
      # * Public class methods
      # * Initializer
      # * Public instance methods
      # * Protected attribute macros (`attr_accessor`, `attr_writer`, `attr_reader`)
      # * Protected instance methods
      # * Private attribute macros (`attr_accessor`, `attr_writer`, `attr_reader`)
      # * Private instance methods
      #
      # NOTE: Simply enabling the cop with `Enabled: true` will not use
      # the example order shown below.
      # To enforce the order of macros like `attr_reader`,
      # you must define both `ExpectedOrder` *and* `Categories`.
      #
      # You can configure the following order:
      #
      # [source,yaml]
      # ----
      #  Layout/ClassStructure:
      #    ExpectedOrder:
      #      - module_inclusion
      #      - constants
      #      - association
      #      - public_attribute_macros
      #      - public_delegate
      #      - macros
      #      - public_class_methods
      #      - initializer
      #      - public_methods
      #      - protected_attribute_macros
      #      - protected_methods
      #      - private_attribute_macros
      #      - private_delegate
      #      - private_methods
      # ----
      #
      # Instead of putting all literals in the expected order, it is also
      # possible to group categories of macros. Visibility levels are handled
      # automatically.
      #
      # [source,yaml]
      # ----
      #  Layout/ClassStructure:
      #    Categories:
      #      association:
      #        - has_many
      #        - has_one
      #      attribute_macros:
      #        - attr_accessor
      #        - attr_reader
      #        - attr_writer
      #      macros:
      #        - validates
      #        - validate
      #      module_inclusion:
      #        - include
      #        - prepend
      #        - extend
      # ----
      #
      # If you only set `ExpectedOrder`
      # without defining `Categories`,
      # macros such as `attr_reader` or `has_many`
      # will not be recognized as part of a category, and their order will not be validated.
      # For example, the following will NOT raise any offenses, even if the order is incorrect:
      #
      # [source,yaml]
      # ----
      # Layout/ClassStructure:
      #   Enabled: true
      #   ExpectedOrder:
      #     - public_attribute_macros
      #     - initializer
      # ----
      #
      # To make it work as expected, you must also specify `Categories` like this:
      #
      # [source,yaml]
      # ----
      # Layout/ClassStructure:
      #   ExpectedOrder:
      #     - public_attribute_macros
      #     - initializer
      #   Categories:
      #     attribute_macros:
      #       - attr_reader
      #       - attr_writer
      #       - attr_accessor
      # ----
      #
      # @safety
      #   Autocorrection is unsafe because class methods and module inclusion
      #   can behave differently, based on which methods or constants have
      #   already been defined.
      #
      #   Constants will only be moved when they are assigned with literals.
      #
      # @example
      #   # bad
      #   # Expect extend be before constant
      #   class Person < ApplicationRecord
      #     has_many :orders
      #     ANSWER = 42
      #
      #     extend SomeModule
      #     include AnotherModule
      #   end
      #
      #   # good
      #   class Person
      #     # extend and include go first
      #     extend SomeModule
      #     include AnotherModule
      #
      #     # inner classes
      #     CustomError = Class.new(StandardError)
      #
      #     # constants are next
      #     SOME_CONSTANT = 20
      #
      #     # afterwards we have public attribute macros
      #     attr_reader :name
      #
      #     # followed by other macros (if any)
      #     validates :name
      #
      #     # then we have public delegate macros
      #     delegate :to_s, to: :name
      #
      #     # public class methods are next in line
      #     def self.some_method
      #     end
      #
      #     # initialization goes between class methods and instance methods
      #     def initialize
      #     end
      #
      #     # followed by other public instance methods
      #     def some_method
      #     end
      #
      #     # protected attribute macros and methods go next
      #     protected
      #
      #     attr_reader :protected_name
      #
      #     def some_protected_method
      #     end
      #
      #     # private attribute macros, delegate macros and methods
      #     # are grouped near the end
      #     private
      #
      #     attr_reader :private_name
      #
      #     delegate :some_private_delegate, to: :name
      #
      #     def some_private_method
      #     end
      #   end
      #
      class ClassStructure < Base
        include VisibilityHelp
        include CommentsHelp
        extend AutoCorrector

        HUMANIZED_NODE_TYPE = {
          casgn: :constants,
          defs: :public_class_methods,
          def: :public_methods,
          sclass: :class_singleton
        }.freeze

        MSG = '`%<category>s` is supposed to appear before `%<previous>s`.'

        # Validates code style on class declaration.
        # Add offense when find a node out of expected order.
        # A node is out of order when its category is expected earlier than
        # the highest-priority category seen so far, so that a low-priority element
        # (even an unmovable one) cannot mask disorder among the elements that follow it.
        # Consecutive elements of the same category are reported only once,
        # on the first element of the group.
        def on_class(class_node)
          # Corrections are registered in reverse source order because an insertion at
          # a given position lands before any insertion already made there;
          # this keeps the source order of nodes moved before the same anchor.
          out_of_order_elements(class_node).reverse_each do |node, category, previous|
            message = format(MSG, category: category, previous: previous)

            add_offense(node, message: message) do |corrector|
              autocorrect(corrector, node)
            end
          end
        end
        alias on_sclass on_class

        private

        def out_of_order_elements(class_node)
          out_of_order = []
          max_index = -1
          previous_category = nil
          walk_over_nested_class_definition(class_node) do |node, category|
            index = expected_order.index(category)
            if index < max_index && category != previous_category
              out_of_order << [node, category, expected_order[max_index]]
            end
            max_index = index if index > max_index
            previous_category = category
          end
          out_of_order
        end

        # Autocorrect by moving the node, together with the contiguous group of
        # same-category elements that follows it, to its expected position.
        def autocorrect(corrector, node)
          return if dynamic_constant?(node)

          anchor = insertion_anchor(node)
          return unless anchor

          anchor_range = source_range_with_comment(anchor)
          # Reversed for the same reason offenses are registered in reverse source order:
          # the last insertion at a position comes first.
          movable_group(node).reverse_each do |group_node|
            current_range = source_range_with_comment(group_node)
            corrector.insert_before(anchor_range, current_range.source)
            corrector.remove(current_range)
          end
        end

        # Classifies a node to match with something in the {expected_order}
        # @param node to be analysed
        # @return String when the node type is a `:block` then
        #   {classify} recursively with the first children
        # @return String when the node type is a `:send` then {find_send_node_category}
        #   by method name
        # @return String otherwise trying to {humanize_node} of the current node
        def classify(node)
          return node.to_s unless node.respond_to?(:type)

          case node.type
          when :block
            classify(node.send_node)
          when :send
            find_send_node_category(node)
          else
            name = humanize_node(node)
            find_category(name) || name
          end.to_s
        end

        # Categorize a node according to the {expected_order}
        # Try to match {categories} values against the node's method_name given
        # also its visibility.
        # @param node to be analysed.
        # @return [String] with the key category or the `method_name` as string
        def find_send_node_category(node)
          name = node.method_name.to_s
          category = find_category(name)
          key = category || name
          visibility_key =
            if node.def_modifier?
              name.end_with?('_class_method') ? "#{name}s" : "#{name}_methods"
            else
              "#{node_visibility(node)}_#{key}"
            end
          expected_order.include?(visibility_key) ? visibility_key : key
        end

        def find_category(name)
          name = name.to_s
          category, = categories.find { |_, names| names.include?(name) }
          category
        end

        def walk_over_nested_class_definition(class_node)
          class_elements(class_node).each do |node|
            classification = classify(node)
            next if ignore?(node, classification)

            yield node, classification
          end
        end

        def class_elements(class_node)
          class_def = class_node.body

          return [] unless class_def

          # Only a multi-statement body (`begin`/`kwbegin`) wraps several elements; any
          # single statement (`def`, `send`, `csend`, `if`, ...) is itself the sole element.
          # Exploding such a node into its children would yield non-node values (e.g. a
          # method-name `Symbol` from a `csend`) and crash later checks.
          if class_def.type?(:begin, :kwbegin)
            flatten_class_elements(class_def)
          else
            [class_def]
          end
        end

        def ignore?(node, classification)
          classification.nil? ||
            classification.to_s.end_with?('=') ||
            expected_order.index(classification).nil? ||
            private_constant?(node)
        end

        def flatten_class_elements(node)
          node.children.compact.flat_map do |child|
            child.kwbegin_type? ? flatten_class_elements(child) : [child]
          end
        end

        def humanize_node(node)
          if node.def_type?
            return :initializer if node.method?(:initialize)

            return "#{node_visibility(node)}_methods"
          end
          HUMANIZED_NODE_TYPE[node.type] || node.type
        end

        def dynamic_constant?(node)
          return false unless node.casgn_type? && node.namespace.nil?

          expression = node.expression
          expression.send_type? &&
            !(expression.method?(:freeze) && expression.receiver&.recursive_basic_literal?)
        end

        # The expected position of the node: the first left sibling within its movable span
        # whose category is expected to appear after the node's.
        # Requiring a strictly later category keeps the order of elements sharing a category stable.
        def insertion_anchor(node)
          index = expected_order.index(classify(node))

          movable_span(node).find do |sibling|
            classification = classify(sibling)

            !ignore?(sibling, classification) && expected_order.index(classification) > index
          end
        end

        # The node together with the contiguous same-category right siblings,
        # so that the whole group moves in a single pass while the offense is
        # reported only on its first element.
        def movable_group(node)
          classification = classify(node)
          group = [node]

          node.right_siblings.each do |sibling|
            break unless classify(sibling) == classification
            break if ignore?(sibling, classification) || dynamic_constant?(sibling)

            group << sibling
          end

          group
        end

        # Left siblings the node may be reordered with: those after the last barrier.
        # Ignored elements within the span are simply jumped over.
        def movable_span(node)
          left_siblings = node.left_siblings
          barrier_index = left_siblings.rindex { |sibling| barrier?(node, sibling) }

          barrier_index ? left_siblings[(barrier_index + 1)..] : left_siblings
        end

        # A dynamic constant blocks every element: the cop does not move such constants,
        # and letting other elements jump over one would change execution order just the same.
        # A bare visibility modifier blocks only the elements whose meaning depends on
        # the visibility section they appear in.
        def barrier?(node, sibling)
          dynamic_constant?(sibling) || (visibility_dependent?(node) && visibility_block?(sibling))
        end

        # Whether moving the node across a bare visibility modifier would change its meaning.
        # This is the case for `def` nodes and for macros whose category is classified by visibility
        # (e.g. `attr_accessor` when the expected order lists `private_attribute_macros`).
        # Inline visibility (`private def foo`, `def self.foo`) travels with the node.
        def visibility_dependent?(node)
          return true if node.def_type?
          return false if !node.send_type? || node.def_modifier?

          key = find_category(node.method_name) || node.method_name.to_s

          VISIBILITY_SCOPES.any? { |visibility| expected_order.include?("#{visibility}_#{key}") }
        end

        def private_constant?(node)
          return false unless node.casgn_type? && node.namespace.nil?
          return false unless (parent = node.parent)

          parent.each_child_node(:send) do |child_node|
            return true if marked_as_private_constant?(child_node, node.name)
          end
          false
        end

        def marked_as_private_constant?(node, name)
          return false unless node.method?(:private_constant)

          node.arguments.any? { |arg| arg.type?(:sym, :str) && arg.value == name }
        end

        def end_position_for(node)
          if node.casgn_type?
            heredoc = find_heredoc(node)
            return heredoc.location.heredoc_end.end_pos + 1 if heredoc
          end

          end_line = buffer.line_for_position(node.source_range.end_pos)
          buffer.line_range(end_line).end_pos
        end

        def begin_pos_with_comment(node)
          first_comment = nil
          (node.first_line - 1).downto(1) do |annotation_line|
            break unless (comment = processed_source.comment_at_line(annotation_line))

            first_comment = comment if whole_line_comment_at_line?(annotation_line)
          end

          start_line_position(first_comment || node)
        end

        def whole_line_comment_at_line?(line)
          /\A\s*#/.match?(processed_source.lines[line - 1])
        end

        def start_line_position(node)
          buffer.line_range(node.loc.line).begin_pos - 1
        end

        def find_heredoc(node)
          node.each_node(:any_str).find(&:heredoc?)
        end

        def buffer
          processed_source.buffer
        end

        # Load expected order from `ExpectedOrder` config.
        # Define new terms in the expected order by adding new {categories}.
        def expected_order
          cop_config['ExpectedOrder']
        end

        # Setting categories hash allow you to group methods in group to match
        # in the {expected_order}.
        def categories
          cop_config['Categories']
        end
      end
    end
  end
end
