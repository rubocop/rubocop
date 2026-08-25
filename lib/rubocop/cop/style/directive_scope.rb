# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for directive scopes that can be expressed with the tighter
      # next-statement forms: a `disable`/`enable` pair, an
      # `enable`/`disable` pair, or a `push`/`pop` with signed arguments
      # wrapping exactly one statement. A statement-scoped directive cannot
      # drift as the surrounding code changes and needs no closing boundary.
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
      #   # bad
      #   # rubocop:disable Metrics/AbcSize
      #   # rubocop:push +Metrics/AbcSize
      #   def foo
      #   end
      #   # rubocop:pop
      #   # rubocop:enable Metrics/AbcSize
      #
      #   # good
      #   # rubocop:disable Metrics/AbcSize
      #   # rubocop:enable-next Metrics/AbcSize
      #   def foo
      #   end
      #   # rubocop:enable Metrics/AbcSize
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
        MSG_ENABLE_PAIR = 'Use `enable-next` instead of an `enable`/`disable` pair ' \
                          'around a single statement.'
        MSG_PUSH_POP = 'Use `%<replacement>s` instead of `push`/`pop` around a single statement.'

        def on_new_investigation
          processed_source.comments.each do |comment|
            directive = DirectiveComment.new(comment)
            next unless comment_config.comment_only_line?(directive.line_number)

            if plain_disable?(directive)
              check_pair(directive)
            elsif signed_push?(directive)
              check_push_pop(directive)
            elsif plain_enable?(directive)
              check_enable_pair(directive)
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

        def plain_enable?(directive)
          directive.enabled? && !directive.enable_next? && !directive.all_cops?
        end

        def signed_push?(directive)
          directive.push? && !directive.signed_args.empty?
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
          pop_line = balancing_pop_line(directive)
          return unless pop_line && comment_config.comment_only_line?(pop_line)
          return unless wraps_single_statement?(directive, pop_line)

          pop_comment = processed_source.comment_at_line(pop_line)
          replacement = push_replacement(directive)
          message = format(MSG_PUSH_POP, replacement: replacement_mode(directive))
          add_offense(directive.comment, message: message) do |corrector|
            corrector.replace(directive.comment, replacement)
            remove_line(corrector, pop_comment)
          end
        end

        # The line of the `pop` balancing this `push`, taking nesting into
        # account, or `nil` when the push is never popped.
        def balancing_pop_line(push_directive)
          depth = 0
          each_directive_after(push_directive) do |directive|
            if directive.push?
              depth += 1
            elsif directive.pop?
              return directive.line_number if depth.zero?

              depth -= 1
            end
          end
          nil
        end

        def each_directive_after(reference)
          processed_source.comments.each do |comment|
            directive = DirectiveComment.new(comment)
            next unless directive.cop_names || directive.push? || directive.pop?

            yield directive if directive.line_number > reference.line_number
          end
        end

        def replacement_mode(directive)
          ops = directive.signed_args.keys.sort
          if ops == ['-']
            'disable-next'
          elsif ops == ['+']
            'enable-next'
          else
            'next'
          end
        end

        def push_replacement(directive)
          text = case replacement_mode(directive)
                 when 'disable-next'
                   "# rubocop:disable-next #{directive.signed_args['-'].join(', ')}"
                 when 'enable-next'
                   "# rubocop:enable-next #{directive.signed_args['+'].join(', ')}"
                 else
                   "# rubocop:next #{directive.cops}"
                 end
          reason = directive.reason
          reason ? "#{text} -- #{reason}" : text
        end

        # An `enable`/`disable` pair around one statement inside a disabled
        # region re-enables the cops for just that statement - `enable-next`
        # says the same without the closing boundary. The pair only counts
        # when the `enable` really closed open disables (otherwise the
        # trailing `disable` opens a new region and the conversion would
        # change what is covered).
        def check_enable_pair(directive)
          closing = enable_pair_closing(directive)
          return unless closing

          add_offense(directive.comment, message: MSG_ENABLE_PAIR) do |corrector|
            corrector.replace(directive.comment,
                              directive.comment.text.sub(/\benable\b/, 'enable-next'))
            remove_line(corrector, closing.comment)
          end
        end

        def enable_pair_closing(directive)
          scope = comment_config.statement_scope_after(directive.line_number)
          return nil unless scope && scope.begin == directive.line_number + 1

          closing = re_disable_below(directive, scope.end + 1)
          closing if closing && closed_open_disables?(directive, closing)
        end

        def re_disable_below(directive, line)
          return nil unless comment_config.comment_only_line?(line)

          comment = processed_source.comment_at_line(line)
          return nil unless comment

          closing = DirectiveComment.new(comment)
          return nil unless closing.disabled? && !closing.disable_next?
          return nil unless closing.raw_cop_names.sort == directive.raw_cop_names.sort

          closing
        end

        # Every cop of the pair must have a range the `enable` closed and a
        # range the trailing `disable` reopened - otherwise the `enable` was
        # not inside a disabled region and the conversion would change what
        # is covered.
        def closed_open_disables?(directive, closing)
          directive.cop_names.all? do |cop|
            ranges = comment_config.cop_disabled_line_ranges[qualified_name(cop)]
            ranges && closed_at?(ranges, directive.line_number) && reopened_by?(ranges, closing)
          end
        end

        def closed_at?(ranges, line)
          ranges.any? { |range| range.end == line }
        end

        def reopened_by?(ranges, closing)
          ranges.any? do |range|
            range.respond_to?(:directive) && range.directive.comment.equal?(closing.comment)
          end
        end

        def qualified_name(cop_name)
          Registry.qualified_cop_name(cop_name.strip, processed_source.file_path,
                                      correct_namespace: false)
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

          ends.first
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

        def remove_line(corrector, comment)
          corrector.remove(range_by_whole_lines(comment.source_range, include_final_newline: true))
        end
      end
    end
  end
end
