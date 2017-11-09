# frozen_string_literal: true

# rubocop:disable Lint/UnneededDisable
module RuboCop
  module Cop
    module Lint
      # This cop checks that there is an `# rubocop:enable ...` statement
      # after a `# rubocop:disable ...` statement. This will prevent leaving
      # cop disables on wide ranges of code, that latter contributors to
      # a file wouldn't be aware of.
      #
      # @example
      #   # good
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   x= 0
      #   # rubocop:enable Layout/SpaceAroundOperators
      #   # y = 1
      #   # EOF
      #
      #   # bad
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   x= 0
      #   # EOF
      #
      class MissingCopEnableDirective < Cop
        MSG = 'Re-enable %s cop with `# rubocop:enable` after disabling it.'
              .freeze

        def investigate(processed_source)
          processed_source.disabled_line_ranges.each do |cop, line_ranges|
            line_ranges.each do |line_range|
              next unless line_range.max == Float::INFINITY
              range = source_range(processed_source.buffer,
                                   line_range.min,
                                   (0..0))
              add_offense(range, location: range, message: format(MSG, cop))
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Lint/UnneededDisable, Layout/SpaceAroundOperators
