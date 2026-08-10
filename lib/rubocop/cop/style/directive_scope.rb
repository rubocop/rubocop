# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for directive scopes that can be expressed with the tighter
      # `disable-next` form: a `disable`/`enable` pair wrapping exactly one
      # statement, or a `push`/`pop` that only disables cops around exactly
      # one statement. A statement-scoped directive cannot drift as the
      # surrounding code changes and needs no closing boundary.
      #
      # @safety
      #   The autocorrection is unsafe because the suppression scope shrinks
      #   from the whole region to the statement: offenses of the suppressed
      #   cops located on the directive lines themselves resurface.
      #
      # @example
      #   # bad
      #   # rubocop:disable Metrics/AbcSize
      #   def foo
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      #   # good
      #   # rubocop:disable-next Metrics/AbcSize
      #   def foo
      #   end
      #
      #   # bad
      #   # rubocop:push -Metrics/AbcSize
      #   def foo
      #   end
      #   # rubocop:pop
      #
      #   # good
      #   # rubocop:disable-next Metrics/AbcSize
      #   def foo
      #   end
      #
      #   # good - the region spans more than one statement
      #   # rubocop:disable Metrics/AbcSize
      #   def foo
      #   end
      #
      #   def bar
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      class DirectiveScope < Base
        include RangeHelp
        extend AutoCorrector

        MSG_PAIR = 'Use `%<mode>s-next` instead of a `%<mode>s`/`enable` pair ' \
                   'around a single statement.'
        MSG_PUSH_POP = 'Use `disable-next` instead of `push`/`pop` around a single statement.'

        def on_new_investigation
          processed_source.comments.each do |comment|
            directive = DirectiveComment.new(comment)
            next unless comment_config.comment_only_line?(directive.line_number)

            if plain_disable?(directive)
              check_pair(directive)
            elsif disable_only_push?(directive)
              check_push_pop(directive)
            end
          end
        end

        private

        def comment_config
          processed_source.comment_config
        end

        def plain_disable?(directive)
          directive.disabled? && !directive.disable_next?
        end

        def disable_only_push?(directive)
          directive.push? && !directive.push_args.empty? && directive.push_args.keys == ['-']
        end

        def check_pair(directive)
          enable = single_statement_closing_directive(directive)
          return unless enable&.enabled?
          return unless enable.raw_cop_names.sort == directive.raw_cop_names.sort

          message = format(MSG_PAIR, mode: directive.mode)
          add_offense(directive.comment, message: message) do |corrector|
            convert_pair(corrector, directive, enable)
          end
        end

        def convert_pair(corrector, directive, enable)
          replacement = directive.comment.text.sub(/\b#{directive.mode}\b/,
                                                   "#{directive.mode}-next")
          corrector.replace(directive.comment, replacement)
          remove_line(corrector, enable.comment)
        end

        def check_push_pop(directive)
          pop = single_statement_closing_directive(directive)
          return unless pop&.pop?

          add_offense(directive.comment, message: MSG_PUSH_POP) do |corrector|
            corrector.replace(directive.comment, disable_next_replacement(directive))
            remove_line(corrector, pop.comment)
          end
        end

        # The directive closing this one's scope, when that scope wraps
        # exactly one statement - `nil` otherwise.
        def single_statement_closing_directive(directive)
          closing_line = single_closing_line(directive)
          return nil unless closing_line

          closing_comment = processed_source.comment_at_line(closing_line)
          return nil unless closing_comment
          return nil unless wraps_single_statement?(directive, closing_line)

          DirectiveComment.new(closing_comment)
        end

        # The single line on which every disabled range opened by this
        # directive ends, or `nil` when the ranges disagree or never close.
        # For a `disable` that is the `enable` line; for a `push` it is the
        # line before the `pop`.
        def single_closing_line(directive)
          ranges = ranges_opened_by(directive)
          return nil if ranges.empty?

          ends = ranges.map(&:end).uniq
          return nil unless ends.size == 1 && ends.first.to_f.finite?

          directive.push? ? ends.first + 1 : ends.first
        end

        def ranges_opened_by(directive)
          comment_config.cop_disabled_line_ranges.each_value.flat_map do |ranges|
            ranges.select do |range|
              range.respond_to?(:directive) && range.directive.comment.equal?(directive.comment)
            end
          end
        end

        # The region wraps a single statement only when the directive sits
        # immediately above it and the closing directive immediately below -
        # any other line inside the region (a comment, a blank line) may
        # carry offenses of the suppressed cops that the tighter scope
        # would no longer cover.
        def wraps_single_statement?(directive, closing_line)
          scope = comment_config.statement_scope_after(directive.line_number)

          !scope.nil? && scope.begin == directive.line_number + 1 && scope.end + 1 == closing_line
        end

        def disable_next_replacement(directive)
          cops = directive.push_args['-'].join(', ')
          reason = directive.reason
          text = "# rubocop:disable-next #{cops}"
          reason ? "#{text} -- #{reason}" : text
        end

        def remove_line(corrector, comment)
          corrector.remove(range_by_whole_lines(comment.source_range, include_final_newline: true))
        end
      end
    end
  end
end
