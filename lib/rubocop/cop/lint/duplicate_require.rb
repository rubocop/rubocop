# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicate `require`s and `require_relative`s.
      #
      # @example
      #   # bad
      #   require 'foo'
      #   require 'bar'
      #   require 'foo'
      #
      #   # good
      #   require 'foo'
      #   require 'bar'
      #
      class DuplicateRequire < Base
        MSG = 'Duplicate `%<method>s` detected.'
        REQUIRE_METHODS = %i[require require_relative].freeze

        def_node_matcher :require_call?, <<~PATTERN
          (send {nil? (const _ :Kernel)} {:#{REQUIRE_METHODS.join(' :')}} _)
        PATTERN

        def on_new_investigation
          # Holds the known required files for a given parent node (used as key)
          @required = Hash.new { |h, k| h[k] = Set.new }.compare_by_identity
          super
        end

        def on_send(node)
          return unless REQUIRE_METHODS.include?(node.method_name) && require_call?(node)
          return if @required[node.parent].add?(node.first_argument)

          add_offense(node, message: format(MSG, method: node.method_name))
        end
      end
    end
  end
end
