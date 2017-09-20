# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for unnecessary require statement.
      #
      # The following features are unnecessary require statement because
      # they are already loaded.
      #
      # % ruby -e 'p $LOADED_FEATURES.reject { |feature| %r|/| =~ feature }'
      # ["enumerator.so", "thread.rb", "rational.so", "complex.so"]
      #
      # @example
      #   # bad
      #   require 'unloaded_feature'
      #   require 'thread'
      #
      #   # good
      #   require 'unloaded_feature'
      class UnneededRequireStatement < Cop
        MSG = 'Remove unnecessary require statement.'.freeze

        LOADED_FEATURES = $LOADED_FEATURES.reject { |feature| %r{/} =~ feature }

        def_node_matcher :unnecessary_require_statement?, <<-PATTERN
          (send nil :require
            (str {#{LOADED_FEATURES.map { |f| "\"#{File.basename(f, '.*')}\"" }.join(' ')}}))
        PATTERN

        def on_send(node)
          return unless unnecessary_require_statement?(node)
          add_offense(node)
        end

        def autocorrect(node)
          ->(corrector) { corrector.remove(node.source_range) }
        end
      end
    end
  end
end
