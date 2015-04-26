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
          lambda do |corrector|
            child = node.children.first

            begin_indent = node.loc.column
            child_indent = child.loc.column

            indent_diff = child_indent - begin_indent

            corrector.replace(
              range_with_surrounding_space(node.loc.expression),
              range_with_surrounding_space(
                child.loc.expression
              ).source.gsub(/^[ \t]{#{indent_diff}}/, '')
            )
          end
        end
      end
    end
  end
end
