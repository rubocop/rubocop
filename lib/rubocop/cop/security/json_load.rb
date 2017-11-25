# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # This cop checks for the use of JSON class methods which have potential
      # security issues.
      #
      # Autocorrect is disabled by default because it's potentially dangerous.
      # If using a stream, like `JSON.load(open('file'))`, it will need to call
      # `#read` manually, like `JSON.parse(open('file').read)`.
      # If reading single values (rather than proper JSON objects), like
      # `JSON.load('false')`, it will need to pass the `quirks_mode: true`
      # option, like `JSON.parse('false', quirks_mode: true)`.
      # Other similar issues may apply.
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
        MSG = 'Prefer `JSON.parse` over `JSON.%<method>s`.'.freeze

        def_node_matcher :json_load, <<-PATTERN
          (send (const {nil? cbase} :JSON) ${:load :restore} ...)
        PATTERN

        def on_send(node)
          json_load(node) do |method|
            add_offense(node,
                        location: :selector,
                        message: format(MSG, method: method))
          end
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'parse') }
        end
      end
    end
  end
end
