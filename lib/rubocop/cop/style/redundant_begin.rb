# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for redundant `begin` blocks.
      #
      # Currently it checks for code like this:
      #
      # @example
      #
      #   def test
      #     begin
      #       ala
      #       bala
      #     rescue StandardError => e
      #       something
      #     end
      #   end
      class RedundantBegin < Cop
        include CheckMethods

        MSG = 'Redundant `begin` block detected.'

        def check(_node, _method_name, _args, body)
          return unless body && body.type == :kwbegin

          add_offense(body, :begin)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(
              node.loc.expression,
              node.children.map { |n| n.loc.expression.source }.join
            )
          end
        end
      end
    end
  end
end
