# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Detects instances of rubocop:enable comments that can be
      # removed.
      #
      # When a comment enables all cops at once `rubocop:enable all`
      # the cop checks whether any cop was actually enabled.
      #
      # @example
      #
      #   # bad
      #   foo = 1
      #   # rubocop:enable Layout/LineLength
      #
      #   # good
      #   foo = 1
      #
      #   # bad
      #   # rubocop:disable Style/StringLiterals
      #   foo = "1"
      #   # rubocop:enable Style/StringLiterals
      #   baz
      #   # rubocop:enable all
      #
      #   # good
      #   # rubocop:disable Style/StringLiterals
      #   foo = "1"
      #   # rubocop:enable all
      #   baz
      #
      #   # bad
      #   foo = 1
      #   # rubocop:pop
      #
      #   # good
      #   # rubocop:push -Style/StringLiterals
      #   foo = "1"
      #   # rubocop:pop
      class RedundantCopEnableDirective < Base
        include RangeHelp
        include SurroundingSpace
        extend AutoCorrector

        MSG = 'Unnecessary enabling of %<cop>s.'
        MSG_ORPHAN_POP = 'Unnecessary `rubocop:pop` without a matching `rubocop:push`.'

        def on_new_investigation
          return if processed_source.blank?

          source = processed_source.raw_source
          check_extra_enables if source.include?('enable')
          check_orphan_pops if source.include?('pop')
        end

        private

        def check_extra_enables
          offenses = processed_source.comment_config.extra_enabled_comments
          offenses.each { |comment, cop_names| register_offense(comment, cop_names) }
        end

        def check_orphan_pops
          push_depth = 0
          processed_source.comments.each do |comment|
            directive = DirectiveComment.new(comment)
            if directive.push?
              push_depth += 1
            elsif directive.pop?
              push_depth.zero? ? register_orphan_pop(directive) : push_depth -= 1
            end
          end
        end

        def register_orphan_pop(directive)
          add_offense(directive.range, message: MSG_ORPHAN_POP) do |corrector|
            corrector.remove(range_with_surrounding_space(directive.range, side: :right))
          end
        end

        def register_offense(comment, cop_names)
          directive = DirectiveComment.new(comment)

          cop_names.each do |name|
            name = name.split('/').first if department?(directive, name)
            add_offense(
              range_of_offense(comment, name),
              message: format(MSG, cop: all_or_name(name))
            ) do |corrector|
              corrector.remove(removal_range(directive, comment, cop_names, name))
            end
          end
        end

        # When every cop on the directive is redundant the whole comment goes, `--` reason
        # included; otherwise just the one cop is spliced out of the list.
        def removal_range(directive, comment, cop_names, name)
          if directive.match?(cop_names)
            range_with_surrounding_space(directive.range_with_reason, side: :right)
          else
            range_with_comma(comment, name)
          end
        end

        def range_of_offense(comment, name)
          start_pos = comment_start(comment) + cop_name_indention(comment, name)
          range_between(start_pos, start_pos + name.size)
        end

        def comment_start(comment)
          comment.source_range.begin_pos
        end

        def cop_name_indention(comment, name)
          # Match the cop name as a whole token so a shorter name is not found inside a
          # longer one that shares its prefix (e.g. `Layout/EmptyLines` in
          # `Layout/EmptyLinesAfterModuleInclusion`).
          comment.text.index(/#{Regexp.escape(name)}(?!\w)/)
        end

        def range_with_comma(comment, name)
          source = comment.source

          begin_pos = cop_name_indention(comment, name)
          end_pos = begin_pos + name.size
          begin_pos = reposition(source, begin_pos, -1)
          end_pos = reposition(source, end_pos, 1)

          range_to_remove(begin_pos, end_pos, comment)
        end

        def range_to_remove(begin_pos, end_pos, comment)
          start = comment_start(comment)
          source = comment.source

          if source[begin_pos - 1] == ','
            range_with_comma_before(start, begin_pos, end_pos)
          elsif source[end_pos] == ','
            range_with_comma_after(comment, start, begin_pos, end_pos)
          else
            range_between(start, comment.source_range.end_pos)
          end
        end

        def range_with_comma_before(start, begin_pos, end_pos)
          range_between(start + begin_pos - 1, start + end_pos)
        end

        # If the list of cops is comma-separated, but without an empty space after the comma,
        # we should **not** remove the prepending empty space, thus begin_pos += 1
        def range_with_comma_after(comment, start, begin_pos, end_pos)
          begin_pos += 1 if comment.source[end_pos + 1] != ' '

          range_between(start + begin_pos, start + end_pos + 1)
        end

        def all_or_name(name)
          name == 'all' ? 'all cops' : name
        end

        def department?(directive, name)
          directive.in_directive_department?(name) && !directive.overridden_by_department?(name)
        end
      end
    end
  end
end
