# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for single-line method definitions.
      # It can optionally accept single-line methods with no body.
      class SingleLineMethods < Cop
        include AutocorrectAlignment

        MSG = 'Avoid single-line method definitions.'.freeze

        def on_def(node)
          return unless node.single_line?
          return if allow_empty? && !node.body

          add_offense(node)
        end
        alias on_defs on_def

        private

        def allow_empty?
          cop_config['AllowIfMethodIsEmpty']
        end

        def autocorrect(node)
          body = node.body

          lambda do |corrector|
            each_part(body) do |part|
              break_line_before(part, node, corrector, 1)
            end

            break_line_before(node.loc.end, node, corrector, 0)

            eol_comment = end_of_line_comment(node.source_range.line)
            move_comment(eol_comment, node, corrector) if eol_comment
          end
        end

        def end_of_line_comment(line)
          processed_source.comments.find { |c| c.loc.line == line }
        end

        def each_part(body)
          return unless body

          if body.begin_type?
            body.each_child_node { |part| yield part.source_range }
          else
            yield body.source_range
          end
        end

        def break_line_before(range, node, corrector, indent_steps)
          corrector.insert_before(
            range,
            "\n" + ' ' * (node.loc.keyword.column +
                          indent_steps * configured_indentation_width)
          )
        end

        def move_comment(eol_comment, node, corrector)
          text = eol_comment.loc.expression.source
          corrector.insert_before(node.source_range,
                                  text + "\n" + (' ' * node.loc.keyword.column))
          corrector.remove(eol_comment.loc.expression)
        end
      end
    end
  end
end
