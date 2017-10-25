# frozen_string_literal: true

# rubocop:disable Lint/UnneededDisable
module RuboCop
  module Cop
    module Lint
      # @example
      #   # good
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   # x= 0
      #   # rubocop:enable Layout/SpaceAroundOperators
      #   # y = 1
      #   # EOF
      #
      #   # bad
      #   # rubocop:disable Layout/SpaceAroundOperators
      #   # x= 0
      #   # EOF
      #
      class EnableStatement < Cop
        MSG = 'Re-enable %s cop with `# rubocop:enable` after disabling it.'
              .freeze

        def investigate(processed_source)
          processed_source.disabled_line_ranges.each do |cop, line_range|
            next unless line_range.any? { |r| r.max == Float::INFINITY }
            range = source_range(processed_source.buffer,
                                 processed_source.lines.size - 1,
                                 (0..0))
            add_offense(range, location: range, message: format(MSG, cop))
          end
        end
      end
    end
  end
end
# rubocop:enable Lint/UnneededDisable, Layout/SpaceAroundOperators
