# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class CollectionMethods < Cop
        MSG = 'Prefer %s over %s.'

        PREFERRED_METHODS = {
          collect: 'map',
          inject: 'reduce',
          detect: 'find',
          find_all: 'select'
        }

        def on_send(node)
          receiver, method_name, *_args = *node

          # a simple(but flawed way) to reduce false positives
          if receiver && PREFERRED_METHODS[method_name]
            add_offence(
              :convention,
              node.loc.expression,
              sprintf(MSG, PREFERRED_METHODS[method_name], method_name)
            )
          end
        end
      end
    end
  end
end
