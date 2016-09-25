# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      class RescueModifier < Cop
        include AutocorrectAlignment

        MSG = 'Avoid using `rescue` in its modifier form.'.freeze

        def investigate(processed_source)
          @modifier_locations = processed_source
                                .tokens
                                .select { |t| t.type == :kRESCUE_MOD }
                                .map(&:pos)
        end

        def on_resbody(node)
          return unless modifier?(node)
          add_offense(node.parent, :expression)
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

        private

        def modifier?(node)
          @modifier_locations.include?(node.loc.keyword)
        end
      end
    end
  end
end
