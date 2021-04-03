# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that predicates are named properly.
      #
      # @example
      #   # bad
      #   def is_even(value)
      #   end
      #
      #   def is_even?(value)
      #   end
      #
      #   # good
      #   def even?(value)
      #   end
      #
      #   # bad
      #   def has_value
      #   end
      #
      #   def has_value?
      #   end
      #
      #   # good
      #   def value?
      #   end
      class PredicateName < Base
        include AllowedMethods

        # @!method dynamic_method_define(node)
        def_node_matcher :dynamic_method_define, <<~PATTERN
          (send nil? #method_definition_macros
            (sym $_)
            ...)
        PATTERN

        def on_send(node)
          dynamic_method_define(node) do |method_name|
            predicate_prefixes.each do |prefix|
              next if allowed_method_name?(method_name.to_s, prefix)

              add_offense(
                node.first_argument.loc.expression,
                message: message(method_name, expected_name(method_name.to_s, prefix))
              )
            end
          end
        end

        def on_def(node)
          predicate_prefixes.each do |prefix|
            method_name = node.method_name.to_s

            next if allowed_method_name?(method_name, prefix)

            add_offense(
              node.loc.name,
              message: message(method_name, expected_name(method_name, prefix))
            )
          end
        end
        alias on_defs on_def

        private

        def allowed_method_name?(method_name, prefix)
          !(method_name.start_with?(prefix) && # cheap check to avoid allocating Regexp
              method_name.match?(/^#{prefix}[^0-9]/)) ||
            method_name == expected_name(method_name, prefix) ||
            method_name.end_with?('=') ||
            allowed_method?(method_name)
        end

        def expected_name(method_name, prefix)
          new_name = if forbidden_prefixes.include?(prefix)
                       method_name.sub(prefix, '')
                     else
                       method_name.dup
                     end
          new_name << '?' unless method_name.end_with?('?')
          new_name
        end

        def message(method_name, new_name)
          "Rename `#{method_name}` to `#{new_name}`."
        end

        def forbidden_prefixes
          cop_config['ForbiddenPrefixes']
        end

        def predicate_prefixes
          cop_config['NamePrefix']
        end

        def method_definition_macros(macro_name)
          cop_config['MethodDefinitionMacros'].include?(macro_name.to_s)
        end
      end
    end
  end
end
