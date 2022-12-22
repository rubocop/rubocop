# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for duplicate elements in Regexp character classes.
      #
      # @example
      #
      #   # bad
      #   r = /[xyx]/
      #
      #   # bad
      #   r = /[0-9x0-9]/
      #
      #   # good
      #   r = /[xy]/
      #
      #   # good
      #   r = /[0-9x]/
      class DuplicateRegexpCharacterClassElement < Base
        include RangeHelp
        extend AutoCorrector

        MSG_REPEATED_ELEMENT = 'Duplicate element inside regexp character class'

        def on_regexp(node)
          each_repeated_character_class_element_loc(node) do |loc|
            add_offense(loc, message: MSG_REPEATED_ELEMENT) do |corrector|
              corrector.remove(loc)
            end
          end
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def each_repeated_character_class_element_loc(node)
          node.parsed_tree&.each_expression do |expr|
            next if skip_expression?(expr)

            seen = Set.new
            enum = expr.expressions.to_enum
            expression_count = expr.expressions.count

            expression_count.times do |current_number|
              current_child = enum.next
              next if within_interpolation?(node, current_child)

              current_child_source = current_child.to_s
              next_child = enum.peek if current_number + 1 < expression_count

              if seen.include?(current_child_source)
                next if start_with_escaped_zero_number?(current_child_source, next_child.to_s)

                yield current_child.expression
              end

              seen << current_child_source
            end
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        private

        def skip_expression?(expr)
          expr.type != :set || expr.token == :intersection
        end

        # Since we blank interpolations with a space for every char of the interpolation, we would
        # mark every space (except the first) as duplicate if we do not skip regexp_parser nodes
        # that are within an interpolation.
        def within_interpolation?(node, child)
          parse_tree_child_loc = child.expression

          interpolation_locs(node).any? { |il| il.overlaps?(parse_tree_child_loc) }
        end

        def start_with_escaped_zero_number?(current_child, next_child)
          # Represents escaped code from `"\00"` (`"\u0000"`) to `"\07"` (`"\a"`).
          current_child == '\\0' && next_child.match?(/[0-7]/)
        end

        def interpolation_locs(node)
          @interpolation_locs ||= {}

          # Cache by loc, not by regexp content, as content can be repeated in multiple patterns
          key = node.loc

          @interpolation_locs[key] ||= node.children.select(&:begin_type?).map(&:source_range)
        end
      end
    end
  end
end
