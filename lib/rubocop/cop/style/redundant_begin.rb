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
        MSG = 'Redundant `begin` block detected.'

        def on_def(node)
          _method_name, _args, body = *node

          check(body)
        end

        def on_defs(node)
          _scope, _method_name, _args, body = *node

          check(body)
        end

        private

        def check(node)
          return unless node && node.type == :kwbegin

          convention(node, :begin)
        end
      end
    end
  end
end
