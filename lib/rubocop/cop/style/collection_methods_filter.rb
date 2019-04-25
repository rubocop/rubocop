# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method name between `filter`,
      # `select` and `find_all` from the Enumerable module.
      #
      # Unfortunately we cannot actually know if a method is from
      # Enumerable or not (static analysis limitation), so this cop
      # can yield some false positives.
      #
      # You can customize the mapping from undesired method to desired method.
      #
      # This cop is only applicable for ruby 2.6 and above.
      #
      # e.g. to use `select` over `find_all`:
      #
      #   Style/CollectionMethods:
      #     PreferredMethods:
      #       find_all: 'select'
      #
      # The default mapping for `PreferredMethods` behaves as follows.
      #
      # @example
      #   # bad
      #   items.find_all
      #   items.select
      #
      #   # good
      #   items.filter
      #
      class CollectionMethodsFilter < CollectionMethods
        extend TargetRubyVersion

        minimum_target_ruby_version 2.6
      end
    end
  end
end
