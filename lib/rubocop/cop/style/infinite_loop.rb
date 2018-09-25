# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use `Kernel#loop` for infinite loops.
      #
      # @example
      #   # bad
      #   while true
      #     work
      #   end
      #
      #   # good
      #   loop do
      #     work
      #   end
      class InfiniteLoop < Cop
        LEADING_SPACE = /\A(\s*)/.freeze

        MSG = 'Use `Kernel#loop` for infinite loops.'.freeze

        def on_while(node)
          return unless node.condition.truthy_literal?

          add_offense(node, location: :keyword)
        end

        def on_until(node)
          return unless node.condition.falsey_literal?

          add_offense(node, location: :keyword)
        end

        alias on_while_post on_while
        alias on_until_post on_until

        def autocorrect(node)
          if node.while_post_type? || node.until_post_type?
            replace_begin_end_with_modifier(node)
          elsif node.modifier_form?
            replace_source(node.source_range, modifier_replacement(node))
          else
            replace_source(non_modifier_range(node), 'loop do')
          end
        end

        private

        def replace_begin_end_with_modifier(node)
          lambda do |corrector|
            corrector.replace(node.body.loc.begin, 'loop do')
            corrector.remove(node.body.loc.end.end.join(node.source_range.end))
          end
        end

        def replace_source(range, replacement)
          lambda do |corrector|
            corrector.replace(range, replacement)
          end
        end

        def modifier_replacement(node)
          if node.single_line?
            'loop { ' + node.body.source + ' }'
          else
            indentation = node.body.loc.expression.source_line[LEADING_SPACE]

            ['loop do', node.body.source.gsub(/^/, configured_indent),
             'end'].join("\n#{indentation}")
          end
        end

        def non_modifier_range(node)
          start_range = node.loc.keyword.begin
          end_range = if node.do?
                        node.loc.begin.end
                      else
                        node.condition.source_range.end
                      end

          start_range.join(end_range)
        end

        def configured_indent
          ' ' * config.for_cop('IndentationWidth')['Width']
        end
      end
    end
  end
end
