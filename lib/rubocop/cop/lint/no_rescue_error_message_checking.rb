# typed: false
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the presence of error message checking within rescue blocks.
      #
      # @example
      #
      #   # bad
      #   begin
      #     something
      #   rescue => e
      #     if e.message.match?(/Duplicate entry/)
      #       handle_error
      #     end
      #   end
      #
      #  # bad
      #  begin
      #    something
      #  rescue => e
      #    unless e.message.match?(/Duplicate entry/)
      #      handle_error
      #    end
      #  end
      #
      #   # good
      #   begin
      #     something
      #   rescue ActiveRecord::RecordNotUnique => e
      #     handle_error
      #   end
      #
      class NoRescueErrorMessageChecking < Base
        MSG = 'Avoid checking error message while handling exceptions. ' \
              'This is brittle and can break easily.'
        METHODS_TO_CHECK = %i[match? include?].freeze

        def on_rescue(node)
          node.each_descendant(:if, :unless).each do |condition_node|
            add_offense(condition_node) if message_check?(condition_node)
          end
        end

        private

        def message_check?(condition_node)
          condition_node.condition&.type == :send &&
            METHODS_TO_CHECK.include?(condition_node.condition.method_name) &&
            condition_node.condition&.receiver &&
            condition_node.condition.receiver.send_type?
        end
      end
    end
  end
end
