# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks expressions wrapping styles for multiline memoization.
      #
      # @example EnforcedStyle: keyword (default)
      #   # bad
      #   foo ||= (
      #     bar
      #     baz
      #   )
      #
      #   # good
      #   foo ||= begin
      #     bar
      #     baz
      #   end
      #
      # @example EnforcedStyle: braces
      #   # bad
      #   foo ||= begin
      #     bar
      #     baz
      #   end
      #
      #   # good
      #   foo ||= (
      #     bar
      #     baz
      #   )
      class MultilineMemoization < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Wrap multiline memoization blocks in `begin` and `end`.'

        def on_or_asgn(node)
          _lhs, rhs = *node

          return unless bad_rhs?(rhs)

          add_offense(rhs, location: node.source_range)
        end

        def autocorrect(node)
          lambda do |corrector|
            if style == :keyword
              keyword_autocorrect(node, corrector)
            else
              corrector.replace(node.loc.begin, '(')
              corrector.replace(node.loc.end, ')')
            end
          end
        end

        private

        def bad_rhs?(rhs)
          return false unless rhs.multiline?

          if style == :keyword
            rhs.begin_type?
          else
            rhs.kwbegin_type?
          end
        end

        def keyword_autocorrect(node, corrector)
          node_buf = node.source_range.source_buffer
          corrector.replace(node.loc.begin, keyword_begin_str(node, node_buf))
          corrector.replace(node.loc.end, keyword_end_str(node, node_buf))
        end

        def keyword_begin_str(node, node_buf)
          indent = config.for_cop('Layout/IndentationWidth')['Width'] || 2
          if node_buf.source[node.loc.begin.end_pos] == "\n"
            'begin'
          else
            "begin\n" + (' ' * (node.loc.column + indent))
          end
        end

        def keyword_end_str(node, node_buf)
          if /[^\s\)]/.match?(node_buf.source_line(node.loc.end.line))
            "\n" + (' ' * node.loc.column) + 'end'
          else
            'end'
          end
        end
      end
    end
  end
end
