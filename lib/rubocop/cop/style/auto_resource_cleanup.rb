# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for cases when you could use a block
      # accepting version of a method that does automatic
      # resource cleanup.
      #
      # @example
      #
      #   # bad
      #   f = File.open('file')
      #
      #   # good
      #   f = File.open('file') do
      #     ...
      #   end
      class AutoResourceCleanup < Cop
        MSG = 'Use the block version of `%s.%s`.'.freeze

        TARGET_METHODS = {
          File: :open
        }.freeze

        def on_send(node)
          TARGET_METHODS.each do |target_class, target_method|
            target_receiver = s(:const, nil, target_class)

            next if node.receiver != target_receiver
            next if node.method_name != target_method
            next if node.parent && node.parent.block_type?
            next if node.block_argument?

            add_offense(node, :expression,
                        format(MSG, target_class, target_method))
          end
        end
      end
    end
  end
end
