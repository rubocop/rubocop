# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
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
        def on_def(node)
          predicate_prefixes.each do |prefix|
            method_name = node.method_name.to_s
            next unless method_name.start_with?(prefix)
            next if method_name == expected_name(method_name, prefix)
            next if predicate_whitelist.include?(method_name)
            add_offense(
              node,
              :name,
              message(method_name, expected_name(method_name, prefix))
            )
          end
        end
        alias on_defs on_def

        private

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
      end
    end
  end
end
