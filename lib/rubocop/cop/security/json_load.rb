# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of unsecure JSON methods.
      #
      # @example
      #   # always offense
      #   JSON.load("{}")
      #   JSON.restore("{}")
      #
      #   # no offense
      #   JSON.parse("{}")
      #
      class JSONLoad < Cop
        MSG = 'Prefer `JSON.parse` instead of `JSON#%s`.'.freeze

        def_node_matcher :json_load, <<-END
          (send (const nil :JSON) ${:load :restore} ...)
        END

        def on_send(node)
          json_load(node) do |method|
            add_offense(node, :selector, format(MSG, method))
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'parse') }
        end
      end
    end
  end
end
