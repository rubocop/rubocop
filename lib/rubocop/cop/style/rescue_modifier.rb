# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      #
      # @example
      #   # bad
      #   some_method rescue handle_error
      #
      #   # good
      #   begin
      #     some_method
      #   rescue
      #     handle_error
      #   end
      class RescueModifier < Cop
        include Alignment
        include RescueNode

        MSG = 'Avoid using `rescue` in its modifier form.'.freeze

        def on_resbody(node)
          return unless rescue_modifier?(node)
          add_offense(node.parent)
        end

        def autocorrect(node)
          operation, rescue_modifier, = *node
          *_, rescue_args = *rescue_modifier

          indent = indentation(node)
          correction =
            "begin\n" \
            "#{operation.source.gsub(/^/, indent)}" \
            "\n#{offset(node)}rescue\n" \
            "#{rescue_args.source.gsub(/^/, indent)}" \
            "\n#{offset(node)}end"

          lambda do |corrector|
            corrector.replace(node.source_range, correction)
          end
        end
      end
    end
  end
end
