# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of unidiomatic method names
      # from the Enumerable module.
      #
      # The current definition of the check is flawed and should be
      # enhanced by check for by blocks & procs as arguments of the
      # methods.
      class CollectionMethods < Cop
        MSG = 'Prefer %s over %s.'

        PREFERRED_METHODS = {
          collect: 'map',
          inject: 'reduce',
          detect: 'find',
          find_all: 'select'
        }

        def on_block(node)
          method, _args, _body = *node

          check_method_node(method)

          super
        end

        def on_send(node)
          _receiver, _method_name, *args = *node

          if args.size == 1 && args.first.type == :block_pass
            check_method_node(node)
          end

          super
        end

        private

        def check_method_node(node)
          _receiver, method_name, *_args = *node

          if PREFERRED_METHODS[method_name]
            add_offence(
              :convention,
              node.loc.selector,
              sprintf(MSG, PREFERRED_METHODS[method_name], method_name)
            )
          end
        end
      end
    end
  end
end
