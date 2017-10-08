# frozen_string_literal: true

module RuboCop
  module Cop
    # Handles `Naming/PredicateName` configuration parameters.
    module ConfigurablePredicateNaming
      def valid_method_name?(method_name, prefix)
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
    end
  end
end
