# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      #
      # Checks the indentation of here document closings.
      #
      # @example
      #
      #   # bad
      #   class Foo
      #     def bar
      #       <<~SQL
      #         'Hi'
      #     SQL
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     def bar
      #       <<~SQL
      #         'Hi'
      #       SQL
      #     end
      #   end
      #
      #   # bad
      #
      #   # heredoc contents is before closing heredoc.
      #   foo arg,
      #       <<~EOS
      #     Hi
      #       EOS
      #
      #   # good
      #   foo arg,
      #       <<~EOS
      #     Hi
      #   EOS
      #
      #   # good
      #   foo arg,
      #       <<~EOS
      #         Hi
      #       EOS
      #
      class ClosingHeredocIndentation < Cop
        include Heredoc

        SIMPLE_HEREDOC = '<<'.freeze
        MSG = '`%<closing>s` is not aligned with `%<opening>s`.'.freeze
        MSG_ARG = '`%<closing>s` is not aligned with `%<opening>s` or ' \
                  'beginning of method definition.'.freeze

        def on_heredoc(node)
          return if heredoc_type(node) == SIMPLE_HEREDOC

          if empty_heredoc?(node) ||
             contents_indentation(node) >= closing_indentation(node)
            return if opening_indentation(node) == closing_indentation(node)
            return if argument_indentation_correct?(node)
          end

          add_offense(node, location: :heredoc_end)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.heredoc_end, indented_end(node))
          end
        end

        private

        def opening_indentation(node)
          indent_level(heredoc_opening(node))
        end

        def empty_heredoc?(node)
          node.loc.heredoc_body.source.empty? || !contents_indentation(node)
        end

        def argument_indentation_correct?(node)
          node.argument? &&
            opening_indentation(
              find_node_used_heredoc_argument(node.parent)
            ) == closing_indentation(node)
        end

        def contents_indentation(node)
          source_lines = node.loc.heredoc_body.source.split("\n")

          source_lines.reject(&:empty?).map do |line|
            indent_level(line)
          end.min
        end

        def closing_indentation(node)
          indent_level(heredoc_closing(node))
        end

        def heredoc_opening(node)
          node.loc.expression.source_line
        end

        def heredoc_closing(node)
          node.loc.heredoc_end.source_line
        end

        def indented_end(node)
          closing_indent = closing_indentation(node)
          opening_indent = opening_indentation(node)
          closing_text = heredoc_closing(node)
          closing_text.gsub(/^\s{#{closing_indent}}/, ' ' * opening_indent)
        end

        def find_node_used_heredoc_argument(node)
          if node.parent && node.parent.send_type?
            find_node_used_heredoc_argument(node.parent)
          else
            node
          end
        end

        def message(node)
          format(
            node.argument? ? MSG_ARG : MSG,
            closing: heredoc_closing(node).strip,
            opening: heredoc_opening(node).strip
          )
        end

        def indent_level(source_line)
          source_line[/\A */].length
        end
      end
    end
  end
end
