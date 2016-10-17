# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of if/unless modifiers with multiple-lines bodies.
      #
      # @example
      #
      #   # bad
      #   {
      #     result: 'this should not happen'
      #   } unless cond
      #
      #   # good
      #   { result: 'ok' } if cond
      class MultilineIfModifier < Cop
        include IfNode
        include StatementModifier
        include AutocorrectAlignment

        MSG = 'Favor a normal %s-statement over a modifier' \
              ' clause in a multiline statement.'.freeze

        def on_if(node)
          return unless modifier_if?(node)

          _cond, body = if_node_parts(node)
          return if body.single_line?

          add_offense(node, :expression)
        end

        private

        def message(node)
          format(MSG, node.loc.keyword.source)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, to_normal_if(node))
          end
        end

        def to_normal_if(node)
          cond, body = if_node_parts(node)
          indented_body = indented_body(body, node)

          condition = "#{node.loc.keyword.source} #{cond.source}"
          indented_end = "#{offset(node)}end"

          "#{condition}\n#{indented_body}\n#{indented_end}"
        end

        def configured_indentation_width
          super || 2
        end

        def indented_body(body, node)
          body_source = "#{offset(node)}#{body.source}"
          body_source.each_line.map do |line|
            if line == "\n"
              line
            else
              line.sub(/^\s{#{offset(node).length}}/, indentation(node))
            end
          end.join
        end
      end
    end
  end
end
