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
      # When comment enables all cops at once `rubocop:enable all`
      # that cop checks whether any cop was actually enabled.
      # @example
      #   # bad
      #   foo = 1
      #   # rubocop:enable Metrics/LineLength
      #
      #   # good
      #   foo = 1
      # @example
      #   # bad
      #   # rubocop:disable Metrics/LineLength
      #   baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaarrrrrrrrrrrrr
      #   # rubocop:enable Metrics/LineLength
      #   baz
      #   # rubocop:enable all
      #
      #   # good
      #   # rubocop:disable Metrics/LineLength
      #   baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaarrrrrrrrrrrrr
      #   # rubocop:enable all
      #   baz
      class UnneededCopEnableDirective < Cop
        include RangeHelp
        include SurroundingSpace

        MSG = 'Unnecessary enabling of %<cop>s.'

        def investigate(processed_source)
          return if processed_source.blank?

          offenses = processed_source.comment_config.extra_enabled_comments
          offenses.each do |comment, name|
            add_offense(
              [comment, name],
              location: range_of_offense(comment, name),
              message: format(MSG, cop: all_or_name(name))
            )
          end
        end

        def autocorrect(comment_and_name)
          lambda do |corrector|
            corrector.remove(range_with_comma(*comment_and_name))
          end
        end

        private

        def range_of_offense(comment, name)
          start_pos = comment_start(comment) + cop_name_indention(comment, name)
          range_between(start_pos, start_pos + name.size)
        end

        def comment_start(comment)
          comment.loc.expression.begin_pos
        end

        def cop_name_indention(comment, name)
          comment.text.index(name)
        end

        def range_with_comma(comment, name)
          source = comment.loc.expression.source

          begin_pos = cop_name_indention(comment, name)
          end_pos = begin_pos + name.size
          begin_pos = reposition(source, begin_pos, -1)
          end_pos = reposition(source, end_pos, 1)

          comma_pos =
            if source[begin_pos - 1] == ','
              :before
            elsif source[end_pos] == ','
              :after
            else
              :none
            end

          range_to_remove(begin_pos, end_pos, comma_pos, comment)
        end

        def range_to_remove(begin_pos, end_pos, comma_pos, comment)
          start = comment_start(comment)
          buffer = processed_source.buffer
          range_class = Parser::Source::Range

          case comma_pos
          when :before
            range_class.new(buffer, start + begin_pos - 1, start + end_pos)
          when :after
            range_class.new(buffer, start + begin_pos, start + end_pos + 1)
          else
            range_class.new(buffer, start, comment.loc.expression.end_pos)
          end
        end

        def all_or_name(name)
          name == 'all' ? 'all cops' : name
        end
      end
    end
  end
end
