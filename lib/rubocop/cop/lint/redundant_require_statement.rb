# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for unnecessary `require` statement.
      #
      # The following features are unnecessary `require` statement because
      # they are already loaded.
      #
      #   ruby -ve 'p $LOADED_FEATURES.reject { |feature| %r|/| =~ feature }'
      #   ruby 2.2.8p477 (2017-09-14 revision 59906) [x86_64-darwin13]
      #   ["enumerator.so", "rational.so", "complex.so", "thread.rb"]
      #
      # This cop targets Ruby 2.2 or higher containing these 4 features.
      #
      # @example
      #   # bad
      #   require 'unloaded_feature'
      #   require 'thread'
      #
      #   # good
      #   require 'unloaded_feature'
      class RedundantRequireStatement < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove unnecessary `require` statement.'

        def_node_matcher :unnecessary_require_statement?, <<~PATTERN
          (send nil? :require
            (str {"enumerator" "rational" "complex" "thread"}))
        PATTERN

        def on_send(node)
          return unless unnecessary_require_statement?(node)

          add_offense(node) do |corrector|
            range = range_with_surrounding_space(range: node.loc.expression, side: :right)

            corrector.remove(range)
          end
        end
      end
    end
  end
end
