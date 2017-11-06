# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies the use of a `&block` parameter and `block.call`
      # where `yield` would do just as well.
      #
      # @example
      #   # bad
      #   def method(&block)
      #     block.call
      #   end
      #   def another(&func)
      #     func.call 1, 2, 3
      #   end
      #
      #   # good
      #   def method
      #     yield
      #   end
      #   def another
      #     yield 1, 2, 3
      #   end
      class RedundantBlockCall < Cop
        MSG = 'Use `yield` instead of `%s.call`.'.freeze
        YIELD = 'yield'.freeze
        OPEN_PAREN = '('.freeze
        CLOSE_PAREN = ')'.freeze
        SPACE = ' '.freeze

        def_node_matcher :blockarg_def, <<-PATTERN
          {(def  _   (args ... (blockarg $_)) $_)
           (defs _ _ (args ... (blockarg $_)) $_)}
        PATTERN

        def_node_search :blockarg_calls, <<-PATTERN
          (send (lvar %1) :call ...)
        PATTERN

        def_node_search :blockarg_assigned?, <<-PATTERN
          (lvasgn %1 ...)
        PATTERN

        def on_def(node)
          blockarg_def(node) do |argname, body|
            next unless body

            calls_to_report(argname, body).each do |blockcall|
              add_offense(blockcall, message: format(MSG, argname))
            end
          end
        end

        private

        def calls_to_report(argname, body)
          return [] if blockarg_assigned?(body, argname)

          calls = to_enum(:blockarg_calls, body, argname)

          return [] if calls.any? { |call| args_include_block_pass?(call) }

          calls
        end

        def args_include_block_pass?(blockcall)
          _receiver, _call, *args = *blockcall

          args.any?(&:block_pass_type?)
        end

        # offenses are registered on the `block.call` nodes
        def autocorrect(node)
          _receiver, _method, *args = *node
          new_source = String.new(YIELD)
          unless args.empty?
            new_source += if parentheses?(node)
                            OPEN_PAREN
                          else
                            SPACE
                          end

            new_source << args.map(&:source).join(', ')
          end

          new_source << CLOSE_PAREN if parentheses?(node) && !args.empty?
          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end
      end
    end
  end
end
