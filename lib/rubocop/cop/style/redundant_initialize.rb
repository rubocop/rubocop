# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `initialize` methods that are redundant.
      #
      # An initializer is redundant if it does not do anything, or if it only
      # calls `super` with the same arguments given to it. If the initializer takes
      # an argument that accepts multiple values (`restarg`, `kwrestarg`, etc.) it
      # will not register an offense, because it allows the initializer to take a different
      # number of arguments as its superclass potentially does.
      #
      # NOTE: If an initializer takes any arguments and has an empty body, RuboCop
      # assumes it to *not* be redundant. This is to prevent potential `ArgumentError`.
      #
      # NOTE: If an initializer argument has a default value, RuboCop assumes it
      # to *not* be redundant.
      #
      # NOTE: Empty initializers are registered as offenses, but it is possible
      # to purposely create an empty `initialize` method to override a superclass's
      # initializer.
      #
      # @safety
      #   This cop is unsafe because removing an empty initializer may alter
      #   the behavior of the code, particularly if the superclass initializer
      #   raises an exception. In such cases, the empty initializer may act as
      #   a safeguard to prevent unintended errors from propagating.
      #
      # @example
      #   # bad
      #   def initialize
      #   end
      #
      #   # bad
      #   def initialize
      #     super
      #   end
      #
      #   # bad
      #   def initialize(a, b)
      #     super
      #   end
      #
      #   # bad
      #   def initialize(a, b)
      #     super(a, b)
      #   end
      #
      #   # good
      #   def initialize
      #     do_something
      #   end
      #
      #   # good
      #   def initialize
      #     do_something
      #     super
      #   end
      #
      #   # good (different number of parameters)
      #   def initialize(a, b)
      #     super(a)
      #   end
      #
      #   # good (default value)
      #   def initialize(a, b = 5)
      #     super
      #   end
      #
      #   # good (default value)
      #   def initialize(a, b: 5)
      #     super
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(_)
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(*)
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(**)
      #   end
      #
      #   # good (changes the parameter requirements)
      #   def initialize(...)
      #   end
      #
      # @example AllowComments: true (default)
      #
      #   # good
      #   def initialize
      #     # Overriding to negate superclass `initialize` method.
      #   end
      #
      # @example AllowComments: false
      #
      #   # bad
      #   def initialize
      #     # Overriding to negate superclass `initialize` method.
      #   end
      #
      class RedundantInitialize < Base
        include CommentsHelp
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove unnecessary `initialize` method.'
        MSG_EMPTY = 'Remove unnecessary empty `initialize` method.'
        VALUE_DISCARDING_BODY_TYPES = %i[
          class module sclass block numblock itblock def defs while until for
        ].freeze
        VALUE_PASSING_BODY_TYPES = %i[when in_pattern resbody].freeze

        # @!method initialize_forwards?(node)
        def_node_matcher :initialize_forwards?, <<~PATTERN
          (def _ (args $arg*) $({super zsuper} ...))
        PATTERN

        # @!method private_definition?(node)
        def_node_matcher :private_definition?, <<~PATTERN
          (send nil? :private def)
        PATTERN

        def on_def(node)
          return if acceptable?(node)

          if node.body.nil?
            register_offense(node, MSG_EMPTY) if node.arguments.empty?
          else
            return if node.body.begin_type?

            if (args, super_node = initialize_forwards?(node))
              return unless same_args?(super_node, args)

              register_offense(node, MSG)
            end
          end
        end

        private

        def register_offense(node, message)
          add_offense(node, message: message) do |corrector|
            corrector.remove(removal_range(node))
          end
        end

        def removal_range(node)
          statement = statement_of(node)
          return shared_line_range(statement) unless own_lines?(statement)

          range = statement.source_range
          return range_with_surrounding_space(range, side: :right) if trailing_comment(statement)

          range_by_whole_lines(range, include_final_newline: true)
        end

        def statement_of(node)
          private_definition?(node.parent) ? node.parent : node
        end

        def acceptable?(node)
          return true unless node.method?(:initialize)

          forwards?(node) || allow_comments?(node) || !removable?(node)
        end

        def forwards?(node)
          node.arguments.each_child_node(:restarg, :kwrestarg, :forward_args, :forward_arg).any?
        end

        def allow_comments?(node)
          return false unless cop_config['AllowComments']

          contains_comments?(node) && !comments_contain_disables?(node, name)
        end

        def removable?(node)
          statement = statement_of(node)
          return false unless statement?(statement)

          own_lines?(statement) || !shared_line_range(statement).nil?
        end

        def own_lines?(node)
          code_on_lines_of(node) == node.source
        end

        def shared_line_range(node)
          return if heredoc_body_after?(node)
          return unless node.parent&.type?(:begin, :kwbegin)

          range = sibling_separator_range(node)
          range unless range.nil? || foreign_heredoc_body_in?(range, node)
        end

        def sibling_separator_range(node)
          range = node.source_range
          if (following = node.right_sibling) && following.first_line == node.last_line
            range.join(following.source_range.begin)
          elsif (preceding = node.left_sibling) && preceding.last_line == node.first_line
            preceding.source_range.end.join(range)
          end
        end

        def heredoc_body_after?(node)
          node.each_descendant(:any_str).any? do |str|
            str.heredoc? && str.loc.heredoc_end.end_pos > node.source_range.end_pos
          end
        end

        # The body of a heredoc opened by another statement would be removed with the range.
        def foreign_heredoc_body_in?(range, node)
          processed_source.ast.each_node(:any_str).any? do |str|
            next false if !str.heredoc? || node.source_range.contains?(str.source_range)

            range.overlaps?(str.loc.heredoc_body)
          end
        end

        def code_on_lines_of(node)
          lines = range_by_whole_lines(node.source_range)
          comment = trailing_comment(node)
          return lines.source.strip.delete_suffix(';').rstrip unless comment

          lines.begin.join(comment.source_range.begin).source.strip
        end

        def trailing_comment(node)
          processed_source.comment_at_line(node.last_line)
        end

        def statement?(node)
          parent = node.parent
          return true if parent.nil? || discards_value_of?(parent, node)

          passes_on_value_of?(parent, node) && statement?(parent)
        end

        def discards_value_of?(parent, node)
          case parent.type
          when :begin, :kwbegin
            !parent.children.last.equal?(node)
          when :ensure
            parent.branch.equal?(node)
          when *VALUE_DISCARDING_BODY_TYPES
            parent.body.equal?(node)
          else
            false
          end
        end

        def passes_on_value_of?(parent, node)
          case parent.type
          when :begin, :kwbegin, :rescue, :ensure
            true
          when :if, :case, :case_match
            !parent.condition.equal?(node)
          when *VALUE_PASSING_BODY_TYPES
            parent.body.equal?(node)
          else
            false
          end
        end

        def same_args?(super_node, args)
          return true if super_node.zsuper_type?

          args.map(&:name) == super_node.arguments.map { |a| a.children[0] }
        end
      end
    end
  end
end
