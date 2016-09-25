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
        include OnMethodDef

        MSG = 'Redundant `begin` block detected.'.freeze

        def on_method_def(_node, _method_name, _args, body)
          return unless body && body.kwbegin_type?

          add_offense(body, :begin)
        end

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
