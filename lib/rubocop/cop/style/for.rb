# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of the `for` keyword or `each` method. The
      # preferred alternative is set in the EnforcedStyle configuration
      # parameter. An `each` call with a block on a single line is always
      # allowed.
      #
      # @example EnforcedStyle: each (default)
      #   # bad
      #   def foo
      #     for n in [1, 2, 3] do
      #       puts n
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     [1, 2, 3].each do |n|
      #       puts n
      #     end
      #   end
      #
      # @example EnforcedStyle: for
      #   # bad
      #   def foo
      #     [1, 2, 3].each do |n|
      #       puts n
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     for n in [1, 2, 3] do
      #       puts n
      #     end
      #   end
      #
      class For < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        EACH_LENGTH = 'each'.length
        PREFER_EACH = 'Prefer `each` over `for`.'.freeze
        PREFER_FOR = 'Prefer `for` over `each`.'.freeze

        def_node_matcher :deconstruct_for, <<-PATTERN
          (for $_item $_enumerable _block)
        PATTERN

        def_node_matcher :deconstruct_each, <<-PATTERN
          (block (send $_enumerable :each) $_ _block)
        PATTERN

        def_node_matcher :extract_variables, <<-PATTERN
          (args $_)
        PATTERN

        def on_for(node)
          if style == :each
            add_offense(node, message: PREFER_EACH) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def on_block(node)
          return if node.single_line?

          return unless node.send_node.method?(:each) &&
                        !node.send_node.arguments?

          if style == :for
            incorrect_style_detected(node)
          else
            correct_style_detected
          end
        end

        def autocorrect(node)
          if style == :each
            autocorrect_to_each(node)
          else
            autocorrect_to_for(node)
          end
        end

        private

        def incorrect_style_detected(node)
          add_offense(node, message: PREFER_FOR) do
            opposite_style_detected
          end
        end

        def autocorrect_to_each(node)
          item, enumerable = deconstruct_for(node)

          end_pos = end_position(node, enumerable)

          replacement_range = replacement_range(node, end_pos)

          enum_source = enumerable_source(enumerable)

          correction = "#{enum_source}.each do |#{item.source}|"
          ->(corrector) { corrector.replace(replacement_range, correction) }
        end

        def end_position(node, enumerable)
          if node.do?
            node.loc.begin.end_pos
          elsif enumerable.begin_type?
            enumerable.loc.end.end_pos
          else
            enumerable.loc.expression.end.end_pos
          end
        end

        def enumerable_source(enumerable)
          return "(#{enumerable.source})" if wrap_into_parentheses?(enumerable)

          enumerable.source
        end

        def wrap_into_parentheses?(enumerable)
          enumerable.irange_type? || enumerable.erange_type?
        end

        def autocorrect_to_for(node)
          enumerable, items = deconstruct_each(node)
          variables = extract_variables(items)

          if variables.nil?
            replacement_range = replacement_range(node, node.loc.begin.end_pos)
            correction = "for _ in #{enumerable.source} do"
          else
            replacement_range = replacement_range(node,
                                                  items.loc.expression.end_pos)
            correction = "for #{variables.source} in #{enumerable.source} do"
          end

          ->(corrector) { corrector.replace(replacement_range, correction) }
        end

        def replacement_range(node, end_pos)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.loc.expression.begin_pos,
                                    end_pos)
        end
      end
    end
  end
end
