# frozen_string_literal: true

# The Lint/UnneededCopEnableDirective cop needs to be disabled so as
# to be able to provide a (bad) example of an unneeded enable.

# rubocop:disable Lint/UnneededCopEnableDirective
module RuboCop
  module Cop
    module Lint
      # This cop detects instances of rubocop:enable comments that can be
      # removed.
      #
      # @example
      #   # bad
      #   foo = 1
      #   # rubocop:enable Metrics/LineLength
      #
      #   # good
      #   foo = 1
      class UnneededCopEnableDirective < Cop
        include RangeHelp

        MSG = 'Unnecessary enabling of %<cop>s.'.freeze

        def investigate(processed_source)
          return if processed_source.blank?
          offenses = processed_source.comment_config.extra_enabled_comments
          offenses.each do |comment, name|
            add_offense(
              [comment, name],
              location: range_of_offense(comment, name),
              message: format(MSG, cop: name)
            )
          end
        end

        def autocorrect(comment_and_name)
          lambda do |corrector|
            comment, name = *comment_and_name
            range = range_of_offense(*comment_and_name)
            index = cop_name_indention(comment, name)
            make_corrections(corrector, comment, name, range, index)
          end
        end

        private

        def range_of_offense(comment, name)
          comment_start = comment.loc.expression.begin_pos
          offense_start = comment_start + cop_name_indention(comment, name)
          range_between(offense_start, offense_start + name.size)
        end

        def cop_name_indention(comment, name)
          comment.text.index(name)
        end

        # rubocop:disable Metrics/AbcSize
        def make_corrections(corrector, comment, name, range, index)
          if comment.text[index - 2] == ','
            corrector.remove(
              range_between(range.begin_pos - 2, range.end_pos)
            )
          elsif comment.text[index + name.size] == ','
            corrector.remove(
              range_between(range.begin_pos, range.end_pos + 2)
            )
          else
            corrector.remove(comment.loc.expression)
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
# rubocop:enable Lint/UnneededCopEnableDirective
