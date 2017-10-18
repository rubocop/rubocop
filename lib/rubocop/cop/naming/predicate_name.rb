# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that predicates are named properly.
      #
      # @example
      #   # bad
      #   def is_even?(value) ...
      #
      #   # good
      #   def even?(value)
      #
      #   # bad
      #   def has_value? ...
      #
      #   # good
      #   def value? ...
      class PredicateName < Cop
        def_node_matcher :dynamic_method_define, <<-PATTERN
          (send nil? #method_define_macros
            (sym $_)
            ...)
        PATTERN

        def on_send(node)
          dynamic_method_define(node) do |method_name|
            predicate_prefixes.each do |prefix|
              next if allowed_method_name?(method_name.to_s, prefix)

              add_offense(
                node,
                location: node.first_argument.loc.expression,
                message: message(method_name,
                                 expected_name(method_name.to_s, prefix))
              )
            end
          end
        end

        def on_def(node)
          predicate_prefixes.each do |prefix|
            method_name = node.method_name.to_s

            next if allowed_method_name?(method_name, prefix)

            add_offense(
              node,
              location: :name,
              message: message(method_name, expected_name(method_name, prefix))
            )
          end
        end
        alias on_defs on_def

        private

        def allowed_method_name?(method_name, prefix)
          !method_name.start_with?(prefix) ||
            method_name == expected_name(method_name, prefix) ||
            predicate_whitelist.include?(method_name)
        end

        def expected_name(method_name, prefix)
          new_name = if prefix_blacklist.include?(prefix)
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

        def prefix_blacklist
          cop_config['NamePrefixBlacklist']
        end

        def predicate_prefixes
          cop_config['NamePrefix']
        end

        def predicate_whitelist
          cop_config['NameWhitelist']
        end

        def method_define_macros(macro_name)
          cop_config['MethodDefineMacros'].include?(macro_name.to_s)
        end
      end
    end
  end
end
