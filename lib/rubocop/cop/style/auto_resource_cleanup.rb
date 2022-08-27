# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for cases when you could use a block
      # accepting version of a method that does automatic
      # resource cleanup.
      #
      # @example
      #
      #   # bad
      #   f = File.open('file')
      #
      #   # good
      #   File.open('file') do |f|
      #     # ...
      #   end
      class AutoResourceCleanup < Base
        MSG = 'Use the block version of `%<class>s.%<method>s`.'

        TARGET_METHODS = { File: :open }.freeze

        RESTRICT_ON_SEND = TARGET_METHODS.values.freeze

        def on_send(node)
          TARGET_METHODS.each do |target_class, target_method|
            next if node.method_name != target_method

            target_receiver = s(:const, nil, target_class)
            next if node.receiver != target_receiver

            next if cleanup?(node)

            add_offense(node, message: format(MSG, class: target_class, method: target_method))
          end
        end

        private

        def cleanup?(node)
          parent = node.parent
          node.block_argument? || (parent && (parent.block_type? || !parent.lvasgn_type?))
        end
      end
    end
  end
end
