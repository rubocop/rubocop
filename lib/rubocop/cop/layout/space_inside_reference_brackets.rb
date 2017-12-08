# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that reference brackets have or don't have
      # surrounding space depending on configuration.
      #
      # @example EnforcedStyle: no_space (default)
      #   # The `no_space` style enforces that reference brackets have
      #   # no surrounding space.
      #
      #   # bad
      #   hash[ :key ]
      #   array[ index ]
      #
      #   # good
      #   hash[:key]
      #   array[index]
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that reference brackets have
      #   # surrounding space.
      #
      #   # bad
      #   hash[:key]
      #   array[index]
      #
      #   # good
      #   hash[ :key ]
      #   array[ index ]
      class SpaceInsideReferenceBrackets < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = '%<command>s space inside reference brackets.'.freeze

        def on_send(node)
          return if node.multiline?
          return unless left_ref_bracket(node)
          left_token = left_ref_bracket(node)
          right_token = right_ref_bracket(node, left_token)

          if style == :no_space
            no_space_offenses(node, left_token, right_token)
          else
            space_offenses(node, left_token, right_token)
          end
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            left_token = left_ref_bracket(node)
            right_token = right_ref_bracket(node, left_token)

            if style == :no_space
              no_space_corrector(corrector, left_token, right_token)
            else
              space_corrector(corrector, left_token, right_token)
            end
          end
        end

        def left_ref_bracket(node)
          line_tokens(node).reverse.find { |t| t.type == :tLBRACK2 }
        end

        def line_tokens(node)
          tokens = processed_source.tokens.select do |t|
            t.pos.line == send_line(node)
          end
          tokens.select { |t| t.pos.end_pos <= node.source_range.end_pos }
        end

        def send_line(node)
          node.source_range.first_line
        end

        def right_ref_bracket(node, token)
          i = line_tokens(node).index(token)
          line_tokens(node).slice(i..-1).find { |t| t.type == :tRBRACK }
        end

        def no_space_offenses(node, left_token, right_token)
          if extra_space?(left_token, :left)
            range = side_space_range(range: left_token.pos, side: :right)
            add_offense(node, location: range,
                              message: format(MSG, command: 'Do not use'))
          end
          return unless extra_space?(right_token, :right)
          range = side_space_range(range: right_token.pos, side: :left)
          add_offense(node, location: range,
                            message: format(MSG, command: 'Do not use'))
        end

        def no_space_corrector(corrector, left_token, right_token)
          if space_after?(left_token)
            range = side_space_range(range: left_token.pos, side: :right)
            corrector.remove(range)
          end
          return unless space_before?(right_token)
          range = side_space_range(range: right_token.pos, side: :left)
          corrector.remove(range)
        end

        def space_offenses(node, left_token, right_token)
          unless extra_space?(left_token, :left)
            add_offense(node, location: left_token.pos,
                              message: format(MSG, command: 'Use'))
          end
          return if extra_space?(right_token, :right) || right_token.nil?
          add_offense(node, location: right_token.pos,
                            message: format(MSG, command: 'Use'))
        end

        def space_corrector(corrector, left_token, right_token)
          unless space_after?(left_token)
            corrector.insert_after(left_token.pos, ' ')
          end
          return if space_before?(right_token)
          corrector.insert_before(right_token.pos, ' ')
        end

        def extra_space?(token, side)
          if side == :left
            token && space_after?(token)
          else
            token && space_before?(token)
          end
        end
      end
    end
  end
end
