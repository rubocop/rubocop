# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant `begin` blocks.
      #
      # Currently it checks for code like this:
      #
      # @example
      #
      #   def redundant
      #     begin
      #       ala
      #       bala
      #     rescue StandardError => e
      #       something
      #     end
      #   end
      #
      #   def preferred
      #     ala
      #     bala
      #   rescue StandardError => e
      #     something
      #   end
      class RedundantBegin < Cop
        include OnMethodDef

        MSG = 'Redundant `begin` block detected.'

        def on_method_def(_node, _method_name, _args, body)
          return unless body && body.type == :kwbegin

          add_offense(body, :begin)
        end

        def autocorrect(node)
          child = node.children.first
          node_range = range_with_surrounding_space(node.loc.expression)
          child_range = range_with_surrounding_space(corrected_range(child))
          columns = child.loc.column - node.loc.column
          child_source = unindent(child_range, columns)

          lambda do |corrector|
            corrector.replace(node_range, child_source)
          end
        end

        def corrected_range(node)
          Parser::Source::Range.new(
            node.loc.expression.source_buffer,
            node.loc.expression.begin_pos,
            corrected_range_end(node)
          )
        end

        def corrected_range_end(node)
          [
            last_heredoc_position(node),
            node.loc.expression.end_pos
          ].compact.max
        end

        def last_heredoc_position(root)
          root
            .each_node
            .select { |node| node.loc.respond_to?(:heredoc_end) }
            .map { |node| node.loc.heredoc_end.end_pos }
            .max
        end

        def unindent(range, columns)
          range.source.gsub(/^[ \t]{#{columns}}/, '')
        end
      end
    end
  end
end
