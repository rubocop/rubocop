# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for `hash` methods that delegate to `Array#hash` without including
      # `self.class`. Including `self.class` ensures instances of different classes
      # have distinct hash values, which is generally expected.
      #
      # @safety
      #   This cop is unsafe because it can produce false positives if the class
      #   intentionally wants instances with the same state to hash equally
      #   regardless of their class.
      #
      # @example
      #
      #   # bad
      #   def hash
      #     [@foo, bar].hash
      #   end
      #
      #   # good
      #   def hash
      #     [self.class, @foo, bar].hash
      #   end
      #
      class HashMissingClass < Base
        extend AutoCorrector
        include Alignment
        include RangeHelp

        MSG = "Include 'self.class' in 'hash' " \
              'to ensure instances of different classes have distinct hash values.'

        # @!method compound_hash(node)
        def_node_matcher :compound_hash, <<~PATTERN
          (def :hash (args)
            {
              (send $array :hash)
              (begin ... (send $array :hash) )
            }
          )
        PATTERN

        # @!method self_class?(node)
        def_node_matcher :self_class?, <<~PATTERN
          (send (self) :class)
        PATTERN

        def on_def(node)
          compound_hash_missing_self_class(node) do |array|
            add_offense(contents_range(array)) do |corrector|
              corrector.insert_after(array.loc.begin, self_class_source_to_insert(array))
            end
          end
        end

        private

        def compound_hash_missing_self_class(node)
          array = compound_hash(node)
          return unless array
          return if array.values.any? { self_class?(_1) }

          yield array
        end

        def self_class_source_to_insert(array)
          return "self.class#{', ' unless array.values.empty?}" unless array.multiline?

          if !array.values.empty? && same_line?(array.loc.begin, array.values.first)
            "self.class,\n#{indentation(array)}"
          else
            "\n#{indentation(array)}self.class,"
          end
        end
      end
    end
  end
end
