# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for unsafe ranges that may include unintended characters.
      #
      # @example
      #
      #   # bad
      #   r = /[A-z]/
      #
      #   # good
      #   r = /[A-Za-z]/
      class UnsafeRange < Base
        include RangeHelp

        MSG = 'Character range may include unintended characters.'
        RANGES = [('a'..'z').freeze, ('A'..'Z').freeze, ('0'..'9').freeze].freeze

        def on_irange(node)
          return unless node.children.compact.all?(&:str_type?)

          range_start, range_end = node.children
          add_offense(node) if unsafe_range?(range_start.value, range_end.value)
        end
        alias on_erange on_irange

        def on_regexp(node)
          each_unsafe_regexp_range(node) do |loc|
            add_offense(loc)
          end
        end

        def each_unsafe_regexp_range(node)
          node.parsed_tree&.each_expression do |expr|
            next if skip_expression?(expr)

            range_pairs(expr).reject do |range_start, range_end|
              next if skip_range?(range_start, range_end)

              next unless unsafe_range?(range_start.first.text, range_end.first.text)

              yield(build_source_range(range_start, range_end))
            end
          end
        end

        private

        def build_source_range(range_start, range_end)
          range_between(
            range_start.first.expression.begin_pos,
            range_end.last.expression.begin_pos + range_end.last.to_s.length
          )
        end

        def range_for(char)
          RANGES.detect do |range|
            range.include?(char)
          end
        end

        def range_pairs(expr)
          RuboCop::Cop::Utils::RegexpRanges.new(expr).pairs
        end

        def unsafe_range?(range_start, range_end)
          range_for(range_start) != range_for(range_end)
        end

        def skip_expression?(expr)
          !(expr.type == :set && expr.token == :character)
        end

        def skip_range?(range_start, range_end)
          [range_start, range_end].any? do |bound|
            # With regexp_parser < 2.7 octal escapes
            # will be an array of multiple expressions.
            # For >= 2.7 it will be a single expression.
            bound.count > 1 || bound.first.type == :escape
          end
        end
      end
    end
  end
end
