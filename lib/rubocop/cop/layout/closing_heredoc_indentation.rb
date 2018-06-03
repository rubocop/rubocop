# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      #
      # Checks the indentation of here document closings.
      #
      # @example
      #   # bad
      #
      #   class Foo
      #     def bar
      #       <<~SQL
      #         'Hi'
      #     SQL
      #     end
      #   end
      #
      #   # good
      #
      #   class Foo
      #     def bar
      #       <<~SQL
      #         'Hi'
      #       SQL
      #     end
      #   end
      #
      class ClosingHeredocIndentation < Cop
        include Heredoc

        MSG = '`%<closing>s` is not aligned with `%<opening>s`.'.freeze

        def on_heredoc(node)
          return if opening_indentation(node) == closing_indentation(node)

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

        def message(node)
          format(
            MSG,
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
