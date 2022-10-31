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

        MSG = '`%<category>s` is supposed to appear before `%<previous>s`.'

        VISIBILITY_CLASS = {
          public: { visibility: :public, category: 'methods' }.freeze,
          protected: { visibility: :protected, category: 'methods' }.freeze,
          private: { visibility: :private, category: 'methods' }.freeze,
          public_class_method: { visibility: :public, category: 'class_methods' }.freeze,
          private_class_method: { visibility: :private, category: 'class_methods' }.freeze
        }.freeze
        private_constant :VISIBILITY_CLASS

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

        def initialize(*)
          super
          @symbolized_categories = categories.to_h do |key, values|
            [key.to_sym, values.map(&:to_sym)]
          end
          @classifer = Utils::ClassChildrenClassifier.new(@symbolized_categories)
          @expected_order_index = expected_order.map.with_index.to_h.transform_keys(&:to_sym)
        end

        def self.support_multiple_source?
          true
        end

        private

        def classify_all(class_node)
          @classification = @classifer.classify_children(class_node)
          @classification.map do |node, classification|
            node if complete_classification(node, classification)
          end.compact
        end

        def complete_classification(_node, classification) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          return unless classification

          categ = classification[:categories]
          # post macros without a particular category and
          # refering only to unknowns are ignored
          # (e.g. `private :some_unknown_method`)
          return if classification[:macro] == :post && categ.nil?

          categ ||= classification[:group]
          visibility = classification[:visibility]
          classification[:group_order] = \
            if categ.is_a?(Array)
              all = categ.map do |name|
                find_group_order(visibility, name)
              end
              classification[:macro] == :pre ? all.min : all.max
            else
              find_group_order(visibility, categ)
            end
        end

        def find_group_order(visibility, categ)
          visibility_categ = :"#{visibility}_#{categ}"
          @expected_order_index[visibility_categ] || @expected_order_index[categ]
        end

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

        # @return [Integer | nil]
        def group_order(node)
          return unless (c = @classification[node])

          c[:group_order]
        end

        def ignore_for_autocorrect?(node, sibling)
          index = group_order(node)
          sibling_index = group_order(sibling)

          sibling_index.nil? ||
            index == sibling_index ||
            dynamic_constant?(node)
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
