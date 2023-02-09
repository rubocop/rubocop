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

            range_pairs(expr).each do |range_start, range_end|
              # If the start/end include multiple expressions
              # it is an octal escape sequence which we can skip.
              next if [range_start, range_end].any? do |bound|
                # With regexp_parser < 2.7 this will be an array of multiple
                # expressions.  For >= 2.7 it will be a single expression.
                bound.count > 1 || bound.first.type == :escape
              end

              next unless unsafe_range?(range_start.first.text, range_end.first.text)

              yield(build_source_range(range_start, range_end))
            end
          end
        end

        private

        def build_source_range(range_start, range_end)
          range_between(
            range_start.first.expression.begin_pos,
            range_end.last.expression.begin_pos + range_end.last.te - range_end.last.ts
          )
        end

        def range_for(char)
          RANGES.detect do |range|
            range.include?(char)
          end
        end

        def range_pairs(expr)
          RangePairs.new(expr).pairs
        end

        # Helper to abstract complexity of building range pairs
        # with octal escape reconstruction (needed for regexp_parser < 2.7).
        class RangePairs
          attr_reader :compound_token, :pairs, :root

          def initialize(root)
            @root = root
            @compound_token = []
            @pairs = []
            populate(root)
          end

          def populate(expr)
            expressions = expr.expressions.to_a

            until expressions.empty?
              current = expressions.shift

              if escaped_octal?(current)
                compound_token << current
                compound_token.concat(pop_octal_digits(expressions))
                # If we have all the digits we can discard.
              end

              next unless current.type == :set

              process_set(expressions, current)
              compound_token.clear
            end
          end

          def process_set(expressions, current)
            case current.token
            when :range
              pairs << compose_range(expressions, current)
            when :character
              # Child expressions may include the range we are looking for.
              populate(current)
            when :intersection
              # Each child expression could have child expressions that lead to ranges.
              current.expressions.each do |intersected|
                populate(intersected)
              end
            end
          end

          def compose_range(expressions, current)
            range_start, range_end = current.expressions
            range_start = if compound_token.size.between?(1, 2) && octal_digit?(range_start.text)
                            compound_token.dup << range_start
                          else
                            [range_start]
                          end
            range_end = [range_end]
            range_end.concat(pop_octal_digits(expressions)) if escaped_octal?(range_end.first)
            [range_start, range_end]
          end

          def escaped_octal?(expr)
            expr.text =~ /^\\[0-7]$/
          end

          def octal_digit?(char)
            ('0'..'7').cover?(char)
          end

          def pop_octal_digits(expressions)
            digits = []

            2.times do
              next unless (next_child = expressions.first)
              next unless next_child.type == :literal && next_child.text =~ /^[0-7]$/

              digits << expressions.shift
            end

            digits
          end
        end

        def unsafe_range?(range_start, range_end)
          range_for(range_start) != range_for(range_end)
        end

        def skip_expression?(expr)
          !(expr.type == :set && expr.token == :character)
        end
      end
    end
  end
end
