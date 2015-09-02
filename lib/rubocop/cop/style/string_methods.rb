# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method names
      # from the String class.
      class StringMethods < Cop
        MSG = 'Prefer `%s` over `%s`.'

        def on_send(node)
          _receiver, method_name, *_args = *node
          return unless preferred_methods[method_name]
          add_offense(node, :selector,
                      format(MSG,
                             preferred_method(method_name),
                             method_name)
                     )
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source))
          end
        end

        private

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
