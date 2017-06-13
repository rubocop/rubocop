# frozen_string_literal: true

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
        MSG = 'Redundant `begin` block detected.'.freeze

        def on_def(node)
          return unless node.body && node.body.kwbegin_type?

          add_offense(node.body, :begin)
        end
        alias on_defs on_def

        private

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end
    end
  end
end
