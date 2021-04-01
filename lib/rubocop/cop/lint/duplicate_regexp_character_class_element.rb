# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicate elements in Regexp character classes.
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

        def each_repeated_character_class_element_loc(node)
          node.parsed_tree&.each_expression do |expr|
            next if expr.type != :set || expr.token == :intersection

            seen = Set.new

            expr.expressions.each do |child|
              next if within_interpolation?(node, child)

              child_source = child.to_s

              yield child.expression if seen.include?(child_source)

              seen << child_source
            end
          end
        end

        private

        # Since we blank interpolations with a space for every char of the interpolation, we would
        # mark every space (except the first) as duplicate if we do not skip regexp_parser nodes
        # that are within an interpolation.
        def within_interpolation?(node, child)
          parse_tree_child_loc = child.expression

          interpolation_locs(node).any? { |il| il.overlaps?(parse_tree_child_loc) }
        end

        def interpolation_locs(node)
          @interpolation_locs ||= {}

          # Cache by loc, not by regexp content, as content can be repeated in multiple patterns
          key = node.loc

          @interpolation_locs[key] ||= node.children.select(&:begin_type?).map do |interpolation|
            interpolation.loc.expression
          end
        end
      end
    end
  end
end
