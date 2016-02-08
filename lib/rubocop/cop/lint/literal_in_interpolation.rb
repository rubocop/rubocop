# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for interpolated literals.
      #
      # @example
      #
      #   "result is #{10}"
      class LiteralInInterpolation < Cop
        MSG = 'Literal interpolation detected.'.freeze

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            final_node = begin_node.children.last
            next unless final_node
            next if special_keyword?(final_node)
            next if final_node.xstr_type?
            next unless final_node.literal?

            add_offense(final_node, :expression)
          end
        end

        def autocorrect(node)
          value = autocorrected_value(node)
          ->(corrector) { corrector.replace(node.parent.source_range, value) }
        end

        private

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.type == :str && !node.loc.respond_to?(:begin)) ||
            node.source_range.is?('__LINE__')
        end

        def autocorrected_value(node)
          case node.type
          when :str
            node.children.last
          when :sym
            autocorrected_value_for_symbol(node)
          else
            node.source.gsub('"', '\"')
          end
        end

        def autocorrected_value_for_symbol(node)
          end_pos =
            node.loc.end ? node.loc.end.begin_pos : node.loc.expression.end_pos

          Parser::Source::Range.new(node.source_range.source_buffer,
                                    node.loc.begin.end_pos,
                                    end_pos).source
        end
      end
    end
  end
end
