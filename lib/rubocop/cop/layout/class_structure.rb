# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks if the code style follows the ExpectedOrder configuration:
      #
      # `Categories` allows us to map macro names into a category.
      #
      # Consider an example of code style that covers the following order:
      #
      # * Module inclusion (include, prepend, extend)
      # * Constants
      # * Associations (has_one, has_many)
      # * Public attribute macros (attr_accessor, attr_writer, attr_reader)
      # * Other macros (validates, validate)
      # * Public class methods
      # * Initializer
      # * Public instance methods
      # * Protected attribute macros (attr_accessor, attr_writer, attr_reader)
      # * Protected instance methods
      # * Private attribute macros (attr_accessor, attr_writer, attr_reader)
      # * Private instance methods
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
      # Instead of putting all literals in the expected order, is also
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
      # @see https://rubystyle.guide#consistent-classes
      class ClassStructure < Base
        include VisibilityHelp
        extend AutoCorrector

        HUMANIZED_NODE_TYPE = {
          casgn: 'constants',
          defs: 'class_methods',
          sclass: 'class_singleton'
        }.freeze

        MSG = '`%<category>s` is supposed to appear before `%<previous>s`.'

        # @!method dynamic_constant?(node)
        def_node_matcher :dynamic_constant?, <<~PATTERN
          (casgn nil? _ (send ...))
        PATTERN

        # Validates code style on class declaration.
        # Add offense when find a node out of expected order.
        def on_class(class_node)
          previous = -1
          classify_all(class_node).each do |node|
            next unless (index = group_order(node))

            if index < previous
              message = format(MSG, category: expected_order[index],
                                    previous: expected_order[previous])
              add_offense(node, message: message) { |corrector| autocorrect(corrector, node) }
            end
            previous = index
          end
        end

        alias on_sclass on_class

        private

        # Autocorrect by swapping between two nodes autocorrecting them
        def autocorrect(corrector, node)
          previous = node.left_siblings.find do |sibling|
            !ignore_for_autocorrect?(node, sibling)
          end
          return unless previous

          current_range = source_range_with_comment(node)
          previous_range = source_range_with_comment(previous)

          corrector.insert_before(previous_range, current_range.source)
          corrector.remove(current_range)
        end

        # @return [Array<Node>] class elements
        def classify_all(class_node)
          @classification = {}
          class_elements(class_node).each do |node|
            classification = complete_classification(node, classify(node))
            @classification[node] = classification
          end
        end

        def complete_classification(node, classification)
          return classification unless (key = classification[:category])

          visibility = classification[:visibility] || node_visibility(node)
          visibility_key = "#{visibility}_#{key}"
          classification[:group_order] =
            expected_order.index(visibility_key) || expected_order.index(key)

          classification
        end

        # @return [Integer | nil]
        def group_order(node)
          @classification[node][:group_order]
        end

        # Classifies a node to match with something in the {expected_order}
        # @param node to be analysed
        # @return [Hash] with keys `category` and `visibility`
        def classify(node)
          node = node.send_node if node.block_type?

          case node.type
          when :send
            classify_macro(node) unless node.receiver
          when :def
            { category: classify_def(node) }
          else
            { category: humanize_node(node) }
          end || {}
        end

        def classify_def(node)
          return 'initializer' if node.method?(:initialize)

          'methods'
        end

        # Categorize a node according to the {expected_order}
        # Try to match {categories} values against the node's method_name given
        # also its visibility.
        # @param node to be analysed.
        # @return [String] with the key category or the `method_name` as string
        def classify_macro(node)
          name = node.method_name
          return { visibility: name, category: 'methods' } if node.def_modifier?

          { category: macro_name_to_category(name) }
        end

        def macro_name_to_category(name)
          name = name.to_s
          category, = categories.find { |_, names| names.include?(name) }
          category || name
        end

        def class_elements(class_node)
          elems = [class_node.body].compact

          loop do
            single = elems.first
            return elems unless elems.size == 1 && (single.begin_type? || single.kwbegin_type?)

            elems = single.children
          end
        end

        def ignore_for_autocorrect?(node, sibling)
          index = group_order(node)
          sibling_index = group_order(sibling)

          sibling_index.nil? ||
            index == sibling_index ||
            dynamic_constant?(node)
        end

        # @return [String]
        def humanize_node(node)
          HUMANIZED_NODE_TYPE[node.type]
        end

        def source_range_with_comment(node)
          begin_pos, end_pos =
            if (node.def_type? && !node.method?(:initialize)) ||
               (node.send_type? && node.def_modifier?)
              start_node = find_visibility_start(node) || node
              end_node = find_visibility_end(node) || node
              [begin_pos_with_comment(start_node),
               end_position_for(end_node) + 1]
            else
              [begin_pos_with_comment(node), end_position_for(node)]
            end

          Parser::Source::Range.new(buffer, begin_pos, end_pos)
        end

        def end_position_for(node)
          heredoc = find_heredoc(node)
          return heredoc.location.heredoc_end.end_pos + 1 if heredoc

          end_line = buffer.line_for_position(node.loc.expression.end_pos)
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
          node.each_node(:str, :dstr, :xstr).find(&:heredoc?)
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
