# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for interpolated literals.
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
      class LiteralInInterpolation < Cop
        include Interpolation
        include RangeHelp
        include PercentLiteral

        MSG = 'Literal interpolation detected.'
        COMPOSITE = %i[array hash pair irange erange].freeze

        def on_interpolation(begin_node)
          final_node = begin_node.children.last
          return unless final_node
          return if special_keyword?(final_node)
          return unless prints_as_self?(final_node)

          add_offense(final_node)
        end

        def autocorrect(node)
          return if node.dstr_type? # nested, fixed in next iteration

          value = autocorrected_value(node)
          ->(corrector) { corrector.replace(node.parent, value) }
        end

        private

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.str_type? && !node.loc.respond_to?(:begin)) ||
            node.source_range.is?('__LINE__')
        end

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
          else
            node.source.gsub('"', '\"')
          end
        end

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

          contents_range(node).source.split(' ').to_s.gsub('"', '\"')
        end

        # Does node print its own source when converted to a string?
        def prints_as_self?(node)
          node.basic_literal? ||
            (COMPOSITE.include?(node.type) &&
              node.children.all? { |child| prints_as_self?(child) })
        end
      end
    end
  end
end
