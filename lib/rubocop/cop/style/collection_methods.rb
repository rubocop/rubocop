# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method names
      # from the Enumerable module.
      #
      # Unfortunately we cannot actually know if a method is from
      # Enumerable or not (static analysis limitation), so this cop
      # can yield some false positives.
      class CollectionMethods < Cop
        MSG = 'Prefer `%s` over `%s`.'

        def on_block(node)
          method, _args, _body = *node

          check_method_node(method)
        end

        def on_send(node)
          _receiver, _method_name, *args = *node
          return unless args.size == 1 && args.first.type == :block_pass

          check_method_node(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source))
          end
        end

        private

        def check_method_node(node)
          _receiver, method_name, *_args = *node

          return unless preferred_methods[method_name]
          add_offense(node, :selector,
                      format(MSG,
                             preferred_method(method_name),
                             method_name)
                     )
        end

        def preferred_method(method)
          preferred_methods[method.to_sym]
        end

        def preferred_methods
          @preferred_methods ||=
            begin
              # Make sure default configuration 'foo' => 'bar' is removed from
              # the total configuration if there is a 'bar' => 'foo' override.
              default = default_cop_config['PreferredMethods']
              merged = cop_config['PreferredMethods']
              overrides = merged.values - default.values
              merged.reject { |key, _| overrides.include?(key) }.symbolize_keys
            end
        end

        def default_cop_config
          ConfigLoader.default_configuration[cop_name]
        end
      end
    end
  end
end
