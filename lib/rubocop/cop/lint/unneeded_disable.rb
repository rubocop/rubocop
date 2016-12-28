# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop detects instances of rubocop:disable comments that can be
      # removed without causing any offenses to be reported. It's implemented
      # as a cop in that it inherits from the Cop base class and calls
      # add_offense. The unusual part of its implementation is that it doesn't
      # have any on_* methods or an investigate method. This means that it
      # doesn't take part in the investigation phase when the other cops do
      # their work. Instead, it waits until it's called in a later stage of the
      # execution. The reason it can't be implemented as a normal cop is that
      # it depends on the results of all other cops to do its work.
      class UnneededDisable < Cop
        include NameSimilarity

        COP_NAME = 'Lint/UnneededDisable'.freeze

        def check(offenses, cop_disabled_line_ranges, comments)
          unneeded_cops = Hash.new { |h, k| h[k] = Set.new }

          each_unneeded_disable(cop_disabled_line_ranges,
                                offenses, comments) do |comment, unneeded_cop|
            unneeded_cops[comment].add(unneeded_cop)
          end

          add_offenses(unneeded_cops)
        end

        def autocorrect(args)
          lambda do |corrector|
            ranges, range = *args # Ranges are sorted by position.

            range = if range.source.start_with?('#')
                      comment_range_with_surrounding_space(range)
                    else
                      directive_range_in_list(range, ranges)
                    end

            corrector.remove(range)
          end
        end

        private

        def comment_range_with_surrounding_space(range)
          # Eat the entire comment, the preceding space, and the preceding
          # newline if there is one.
          original_begin = range.begin_pos
          range = range_with_surrounding_space(range, :left, true)
          range_with_surrounding_space(range, :right,
                                       # Special for a comment that
                                       # begins the file: remove
                                       # the newline at the end.
                                       original_begin.zero?)
        end

        def directive_range_in_list(range, ranges)
          # Is there any cop between this one and the end of the line, which
          # is NOT being removed?
          if ends_its_line?(ranges.last) && trailing_range?(ranges, range)
            # Eat the comma on the left.
            range = range_with_surrounding_space(range, :left)
            range = range_with_surrounding_comma(range, :left)
          end

          range = range_with_surrounding_comma(range, :right)
          # Eat following spaces up to EOL, but not the newline itself.
          range_with_surrounding_space(range, :right, false)
        end

        def each_unneeded_disable(cop_disabled_line_ranges, offenses, comments)
          disabled_ranges = cop_disabled_line_ranges[COP_NAME] || [0..0]

          cop_disabled_line_ranges.each do |cop, line_ranges|
            each_already_disabled(line_ranges, comments) do |comment|
              yield comment, cop
            end

            line_ranges.each do |line_range|
              comment = comments.find { |c| c.loc.line == line_range.begin }

              unless all_disabled?(comment)
                next if ignore_offense?(disabled_ranges, line_range)
              end

              unneeded_cop = find_unneeded(comment, offenses, cop, line_range)
              yield comment, unneeded_cop if unneeded_cop
            end
          end
        end

        def each_already_disabled(line_ranges, comments)
          line_ranges.each_cons(2) do |previous_range, range|
            next if previous_range.end != range.begin

            # If a cop is disabled in a range that begins on the same line as
            # the end of the previous range, it means that the cop was
            # already disabled by an earlier comment. So it's unneeded
            # whether there are offenses or not.
            yield comments.find { |c| c.loc.line == range.begin }
          end
        end

        def find_unneeded(comment, offenses, cop, line_range)
          if all_disabled?(comment)
            'all' if offenses.none? { |o| line_range.cover?(o.line) }
          else
            cop_offenses = offenses.select { |o| o.cop_name == cop }
            cop if cop_offenses.none? { |o| line_range.cover?(o.line) }
          end
        end

        def all_disabled?(comment)
          comment.text =~ /rubocop:disable\s+all\b/
        end

        def ignore_offense?(disabled_ranges, line_range)
          disabled_ranges.any? do |range|
            range.cover?(line_range.min) && range.cover?(line_range.max)
          end
        end

        def directive_count(comment)
          match = comment.text.match(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
          _, cops_string = match.captures
          cops_string.split(/,\s*/).size
        end

        def add_offenses(unneeded_cops)
          unneeded_cops.each do |comment, cops|
            if all_disabled?(comment) ||
               directive_count(comment) == cops.size
              add_offense_for_entire_comment(comment, cops)
            else
              add_offense_for_some_cops(comment, cops)
            end
          end
        end

        def add_offense_for_entire_comment(comment, cops)
          location = comment.loc.expression
          cop_list = cops.sort.map { |c| describe(c) }
          add_offense([[location], location], location,
                      "Unnecessary disabling of #{cop_list.join(', ')}.")
        end

        def add_offense_for_some_cops(comment, cops)
          cop_ranges = cops.map { |c| [c, cop_range(comment, c)] }
          cop_ranges.sort_by! { |_, r| r.begin_pos }
          ranges = cop_ranges.map { |_, r| r }

          cop_ranges.each do |cop, range|
            add_offense([ranges, range], range,
                        "Unnecessary disabling of #{describe(cop)}.")
          end
        end

        def cop_range(comment, cop)
          matching_range(comment.loc.expression, cop) ||
            matching_range(comment.loc.expression, Badge.parse(cop).cop_name) ||
            raise("Couldn't find #{cop} in comment: #{comment.text}")
        end

        def matching_range(haystack, needle)
          offset = (haystack.source =~ Regexp.new(Regexp.escape(needle)))
          return unless offset
          offset += haystack.begin_pos
          Parser::Source::Range.new(haystack.source_buffer, offset,
                                    offset + needle.size)
        end

        def trailing_range?(ranges, range)
          ranges
            .drop_while { |r| !r.equal?(range) }
            .each_cons(2)
            .map { |r1, r2| r1.end.join(r2.begin).source }
            .all? { |intervening| intervening =~ /\A\s*,\s*\Z/ }
        end

        def describe(cop)
          if cop == 'all'
            'all cops'
          elsif all_cop_names.include?(cop)
            "`#{cop}`"
          else
            similar = find_similar_name(cop, [])
            if similar
              "`#{cop}` (did you mean `#{similar}`?)"
            else
              "`#{cop}` (unknown cop)"
            end
          end
        end

        def collect_variable_like_names(scope)
          all_cop_names.each { |name| scope << name }
        end

        def all_cop_names
          @all_cop_names ||= Cop.registry.names
        end
      end
    end
  end
end
