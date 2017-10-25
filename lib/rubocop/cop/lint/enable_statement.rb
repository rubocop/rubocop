# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # @example
      #   # bad
      #   # rubocop:disable _cop
      #   # Source code
      #   # EOF
      #
      #   # good
      #   # rubocop:disable _cop
      #   x = 0
      #   # rubocop:enable _cop
      #   # Some other code
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
