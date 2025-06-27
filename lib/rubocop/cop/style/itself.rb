# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for consistency for blocks that only return the block variable.
      #
      # NOTE: Autocorrection is not supported for `EnforceStyle: named_parameter` as
      # RuboCop cannot guess what variable name to use.
      #
      # @example EnforcedStyle: itself (default)
      #   # bad
      #   foo { |x| x }
      #   foo { _1 }
      #   foo { it }
      #
      #   # good
      #   foo(&:itself)
      #
      # @example EnforcedStyle: it (default)
      #   # bad
      #   foo { |x| x }
      #   foo { _1 }
      #   foo(&:itself)
      #
      #   # good
      #   foo { it }
      #
      # @example EnforcedStyle: named_parameter (default)
      #   # bad
      #   foo { it }
      #   foo { _1 }
      #   foo(&:itself)
      #
      #   # good
      #   foo { |x| x }
      class Itself < Base
        extend AutoCorrector
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_ITSELF = 'Prefer `&:itself`.'
        MSG_IT = 'Prefer `{ it }`.'
        MSG_NAMED_PARAMETER = 'Prefer a block in the form `{ |x| x }`.'

        # @!method block_offense?(node)
        def_node_matcher :block_offense?, <<~PATTERN
          (block _ (args (arg _name)) (lvar _name))
        PATTERN

        # @!method numblock_offense?(node)
        def_node_matcher :numblock_offense?, <<~PATTERN
          (numblock _ 1 (lvar :_1))
        PATTERN

        # @!method itblock_offense?(node)
        def_node_matcher :itblock_offense?, <<~PATTERN
          (itblock _ :it (lvar :it))
        PATTERN

        # @!method itself_block_pass?(node)
        def_node_matcher :itself_block_pass?, <<~PATTERN
          ^(send _ _ (block-pass (sym :itself)))
        PATTERN

        def on_block(node)
          return if named_parameter?
          return unless block_offense?(node)

          register_block_offense(node, message)
        end

        def on_numblock(node)
          return unless numblock_offense?(node)

          register_block_offense(node, message)
        end

        def on_itblock(node)
          return if it?
          return unless itblock_offense?(node)

          register_block_offense(node, message)
        end

        def on_block_pass(node)
          return if itself?
          return unless itself_block_pass?(node)

          add_offense(node, message: message) do |corrector|
            send_node = node.parent

            range = if send_node.loc?(:begin)
                      send_node.loc.begin.join(send_node.loc.end)
                    else
                      node.source_range
                    end

            range = range_with_surrounding_space(range: range, side: :left)
            autocorrect(corrector, range, " #{replacement}")
          end
        end

        private

        def register_block_offense(node, message)
          block = node.loc.begin.join(node.loc.end)

          add_offense(block, message: message) do |corrector|
            if itself?
              autocorrect_itself(corrector, block, node.send_node)
            else
              autocorrect(corrector, block, replacement)
            end
          end
        end

        def autocorrect(corrector, range, replacement)
          return if named_parameter?

          corrector.replace(range, replacement)
        end

        def autocorrect_itself(corrector, block, send_node)
          range = range_with_surrounding_space(range: block, side: :left)

          if send_node.arguments.any?
            corrector.remove(range)
            corrector.insert_after(send_node.last_argument, ', &:itself')
          else
            corrector.replace(range, '(&:itself)')
          end
        end

        def message(_range = nil)
          if itself?
            MSG_ITSELF
          elsif it?
            MSG_IT
          elsif named_parameter?
            MSG_NAMED_PARAMETER
          end
        end

        def itself?
          style == :itself
        end

        def it?
          style == :it
        end

        def named_parameter?
          style == :named_parameter
        end

        def replacement
          if itself?
            '&:itself'
          elsif it?
            '{ it }'
          end
        end
      end
    end
  end
end
