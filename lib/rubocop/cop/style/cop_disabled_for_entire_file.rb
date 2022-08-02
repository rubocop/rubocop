# frozen_string_literal: true

module RuboCop
  module Cop
    # rubocop:disable Lint/RedundantCopDisableDirective
    module Style
      # Enforces that disabling cops for an entire file happens in a config
      # file, rather than by wrapping the entire file in `rubocop:disable` and
      # `rubocop:enable` comments.
      #
      # @example
      #   # bad
      #   # rubocop:disable Department/CopName
      #   entire_file
      #   # rubocop:enable Department/CopName
      #
      #   # bad
      #   # rubocop:todo Department/CopName
      #   entire_file
      #   # rubocop:enable Department/CopName
      #
      #   # good
      #   # Department/CopName disabled in config, such as .rubocop.yml or .rubocop_todo.yml
      #   entire_file
      #
      #   # good
      #   code
      #   # rubocop:disable Department/CopName
      #   subset_of_code
      #   # rubocop:enable Department/CopName
      #   more_code
      class CopDisabledForEntireFile < Base
        # rubocop:enable Lint/RedundantCopDisableDirective

        MSG = 'Prefer using directives on smaller sections of code, ' \
              'or if you need to disable the entire file, do it in your configuration file.'

        def on_new_investigation
          return if disabled_ranges.empty?

          disabled_ranges.each do |disabled_range|
            next unless disabled_range.cover?(code_range)

            add_offense(processed_source.comment_at_line(disabled_range.begin))
          end
        end

        private

        def disabled_ranges
          @disabled_ranges ||= processed_source
                               .disabled_line_ranges
                               .each_value.with_object(Set.new) do |ranges, set|
                                 set.merge(excluding_in_line_disabled_ranges(ranges))
                               end
        end

        def excluding_in_line_disabled_ranges(ranges)
          # block disable directives always include the lines the comments are on,
          # so are never less than two lines long
          ranges.reject { |range| range.size < 2 }
        end

        def code_range
          @code_range ||= Range.new(
            *processed_source.sorted_tokens.reject(&:comment?).map(&:line).minmax
          )
        end
      end
    end
  end
end
