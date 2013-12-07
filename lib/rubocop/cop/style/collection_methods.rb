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

        def preferred_methods
          if cop_config['PreferredMethods']
            cop_config['PreferredMethods'].symbolize_keys
          end
        end

        def on_block(node)
          method, _args, _body = *node

          check_method_node(method)
        end

        def on_send(node)
          _receiver, _method_name, *args = *node

          if args.size == 1 && args.first.type == :block_pass
            check_method_node(node)
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source))
          end
        end

        private

        def check_method_node(node)
          _receiver, method_name, *_args = *node

          if preferred_methods[method_name]
            add_offence(
              node, :selector,
              sprintf(MSG,
                      preferred_method(method_name),
                      method_name)
            )
          end
        end

        def preferred_method(method)
          preferred_methods[method.to_sym]
        end
      end
    end
  end
end
