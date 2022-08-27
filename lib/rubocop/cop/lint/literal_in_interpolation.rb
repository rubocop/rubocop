# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for interpolated literals.
      #
      # @example
      #
      #   # bad
      #
      #   "result is #{10}"
      #
      # @example
      #
      #   # good
      #
      #   "result is 10"
      class LiteralInInterpolation < Base
        include Interpolation
        include RangeHelp
        include PercentLiteral
        extend AutoCorrector

        MSG = 'Literal interpolation detected.'
        COMPOSITE = %i[array hash pair irange erange].freeze

        def on_interpolation(begin_node)
          final_node = begin_node.children.last
          return unless offending?(final_node)

          # %W and %I split the content into words before expansion
          # treating each interpolation as a word component, so
          # interpolation should not be removed if the expanded value
          # contains a space character.
          expanded_value = autocorrected_value(final_node)
          return if in_array_percent_literal?(begin_node) && /\s/.match?(expanded_value)

          add_offense(final_node) do |corrector|
            return if final_node.dstr_type? # nested, fixed in next iteration

            corrector.replace(final_node.parent, expanded_value)
          end
        end

        private

        def offending?(node)
          node &&
            !special_keyword?(node) &&
            prints_as_self?(node) &&
            # Special case for Layout/TrailingWhitespace
            !(space_literal?(node) && ends_heredoc_line?(node))
        end

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.str_type? && !node.loc.respond_to?(:begin)) || node.source_range.is?('__LINE__')
        end

        # rubocop:disable Metrics/MethodLength
        def autocorrected_value(node)
          case node.type
          when :int
            node.children.last.to_i.to_s
          when :float
            node.children.last.to_f.to_s
          when :str
            autocorrected_value_for_string(node)
          when :sym
            autocorrected_value_for_symbol(node)
          when :array
            autocorrected_value_for_array(node)
          when :nil
            ''
          else
            node.source.gsub('"', '\"')
          end
        end
        # rubocop:enable Metrics/MethodLength

        def autocorrected_value_for_string(node)
          if node.source.start_with?("'", '%q')
            node.children.last.inspect[1..-2]
          else
            node.children.last
          end
        end

        def autocorrected_value_for_symbol(node)
          end_pos =
            node.loc.end ? node.loc.end.begin_pos : node.loc.expression.end_pos

          range_between(node.loc.begin.end_pos, end_pos).source
        end

        def autocorrected_value_for_array(node)
          return node.source.gsub('"', '\"') unless node.percent_literal?

          contents_range(node).source.split.to_s.gsub('"', '\"')
        end

        # Does node print its own source when converted to a string?
        def prints_as_self?(node)
          node.basic_literal? ||
            (COMPOSITE.include?(node.type) && node.children.all? { |child| prints_as_self?(child) })
        end

        def space_literal?(node)
          node.str_type? && node.value.blank?
        end

        def ends_heredoc_line?(node)
          grandparent = node.parent.parent
          return false unless grandparent&.dstr_type? && grandparent&.heredoc?

          line = processed_source.lines[node.last_line - 1]
          line.size == node.loc.last_column + 1
        end

        def in_array_percent_literal?(node)
          parent = node.parent
          return false unless parent.dstr_type? || parent.dsym_type?

          grandparent = parent.parent
          grandparent&.array_type? && grandparent&.percent_literal?
        end
      end
    end
  end
end
