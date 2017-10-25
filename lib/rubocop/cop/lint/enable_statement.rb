# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Lint
      # TODO: Write cop description and example of bad / good code.
      #
      # @example
      #   # bad
      #   # rubocop:disable Lint/EnableStatement
      #   x = 0
      #   # Some other code
      #   # EOF
      #
      #   # good
      #   # rubocop:disable Lint/EnableStatement
      #   x = 0
      #   # rubocop:enable Lint/EnableStatement
      #   # Some other code
      #   # EOF
      #
      class EnableStatement < Cop
        # TODO: Implement the cop into here.
        #
        # In many cases, you can use a node matcher for matching node pattern.
        # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
        #
        # For example
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
