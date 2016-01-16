# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies the use of a `&block` parameter and `block.call`
      # where `yield` would do just as well.
      #
      # @example
      #   @bad
      #   def method(&block)
      #     block.call
      #   end
      #   def another(&func)
      #     func.call 1, 2, 3
      #   end
      #
      #   @good
      #   def method
      #     yield
      #   end
      #   def another
      #     yield 1, 2, 3
      #   end
      class RedundantBlockCall < Cop
        MSG = 'Use `yield` instead of `%s.call`.'.freeze

        def_node_matcher :blockarg_def, <<-END
          {(def  _   (args ... (blockarg $_)) $_)
           (defs _ _ (args ... (blockarg $_)) $_)}
        END

        def_node_search :blockarg_calls, <<-END
          (send (lvar %1) :call ...)
        END

        def on_def(node)
          blockarg_def(node) do |argname, body|
            next unless body
            blockarg_calls(body, argname) do |blockcall|
              add_offense(blockcall, :expression, format(MSG, argname))
            end
          end
        end

        # offenses are registered on the `block.call` nodes
        def autocorrect(node)
          _receiver, _method, *args = *node
          new_source = 'yield'
          new_source += ' ' unless args.empty?
          new_source += args.map(&:source).join(', ')
          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end
      end
    end
  end
end
