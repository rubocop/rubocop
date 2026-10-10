# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces the use of `Array#push(item)` instead of `Array#concat([item])`
      # to avoid redundant array literals.
      #
      # @safety
      #   This cop is unsafe, as it can produce false positives if the receiver
      #   is not an `Array` object.
      #
      # @example
      #
      #   # bad
      #   list.concat([foo])
      #   list.concat([bar, baz])
      #   list.concat([qux, quux], [corge])
      #
      #   # good
      #   list.push(foo)
      #   list.push(bar, baz)
      #   list.push(qux, quux, corge)
      #
      class ConcatArrayLiterals < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'
        MSG_FOR_PERCENT_LITERALS =
          'Use `push` with elements as arguments without array brackets instead of `%<current>s`.'
        RESTRICT_ON_SEND = %i[concat].freeze

        # `Style/MethodCallWithArgsParentheses` removing the parentheses of the `push(...)`
        # this cop writes in the same pass drops the line continuation a multiline call needs.
        # `Style/TrailingCommaInArguments` adds a comma after the array literal this cop
        # replaces with its elements in the same pass.
        def self.autocorrect_incompatible_with
          [Style::MethodCallWithArgsParentheses, Style::TrailingCommaInArguments]
        end

        # rubocop:disable-next Metrics
        def on_send(node)
          return if node.arguments.empty?
          return unless node.arguments.all?(&:array_type?)

          offense = offense_range(node)
          current = offense.source

          if (use_percent_literal = node.arguments.any?(&:percent_literal?))
            if percent_literals_includes_only_basic_literals?(node)
              prefer = preferred_method(node)
              message = format(MSG, prefer: prefer, current: current)
            else
              message = format(MSG_FOR_PERCENT_LITERALS, current: current)
            end
          else
            prefer = preferred_method(node)
            message = format(MSG, prefer: prefer, current: current)
          end

          add_offense(offense, message: message) do |corrector|
            if use_percent_literal
              next unless prefer

              rebuild_call(corrector, offense, prefer)
            elsif node.arguments.any? { |argument| argument.children.empty? }
              # In-place bracket removal would leave dangling commas (e.g.
              # `concat([], [b])` -> `push(, b)`), so rebuild the call instead.
              rebuild_call(corrector, offense, preferred_method(node))
            else
              remove_brackets(corrector, node)
            end
          end
        end
        alias on_csend on_send

        private

        def offense_range(node)
          node.loc.selector.join(node.source_range.end)
        end

        def preferred_method(node)
          new_arguments =
            node.arguments.flat_map do |arg|
              if arg.percent_literal?
                arg.children.map { |child| child.value.inspect }
              else
                arg.children.map(&:source)
              end
            end.join(', ')

          "push(#{new_arguments})"
        end

        def percent_literals_includes_only_basic_literals?(node)
          node.arguments.select(&:percent_literal?).all? do |arg|
            arg.children.all? { |child| child.type?(:str, :sym) }
          end
        end

        def rebuild_call(corrector, offense, replacement)
          # The comments inside the call would be lost.
          return if comment_in?(offense)

          corrector.replace(offense, replacement)
        end

        def comment_in?(range)
          processed_source.each_comment_in_lines(range.line..range.last_line).any? do |comment|
            range.contains?(comment.source_range)
          end
        end

        def remove_brackets(corrector, node)
          closing_ranges = node.arguments.map { |argument| closing_bracket_range(node, argument) }
          # A comment or a heredoc body there can't be moved out of the way.
          return unless closing_ranges.all? { |range| range.source.match?(/\A[\s,]*\]\z/) }

          corrector.replace(node.loc.selector, 'push')
          node.arguments.zip(closing_ranges) do |argument, closing_range|
            corrector.remove(argument.loc.begin)
            corrector.remove(closing_range)
          end
        end

        # Whatever sits between the last element and the `]` of an array that isn't the
        # last argument would end up before the following comma (a newline before it is a
        # syntax error), so it's removed along with the `]`.
        def closing_bracket_range(node, argument)
          return argument.loc.end if argument.equal?(node.last_argument)

          range_between(argument.children.last.source_range.end_pos, argument.loc.end.end_pos)
        end
      end
    end
  end
end
