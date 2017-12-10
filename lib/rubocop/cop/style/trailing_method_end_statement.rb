# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing code after the method definition.
      #
      # @example
      #   # bad
      #   def some_method
      #   do_stuff; end
      #
      #   def do_this(x)
      #     baz.map { |b| b.this(x) } end
      #
      #   def foo
      #     block do
      #       bar
      #     end end
      #
      #   # good
      #   def some_method
      #     do_stuff
      #   end
      #
      #   def do_this(x)
      #     baz.map { |b| b.this(x) }
      #   end
      #
      #   def foo
      #     block do
      #       bar
      #     end
      #   end
      #
      class TrailingMethodEndStatement < Cop
        include AutocorrectAlignment

        MSG = 'Place the end statement of a multi-line method on ' \
              'its own line.'.freeze

        def on_def(node)
          return unless trailing_end?(node)

          add_offense(node.to_a.last, location: end_token.pos)
        end

        private

        def trailing_end?(node)
          node.body &&
            node.multiline? &&
            end_token &&
            body_and_end_on_same_line?
        end

        def end_token
          @end_token ||= processed_source.tokens.reverse.find do |token|
            token.type == :kEND
          end
        end

        def body_and_end_on_same_line?
          end_token.line == token_before_end.line
        end

        def token_before_end
          @token_before_end ||= begin
            i = processed_source.tokens.index(end_token)
            processed_source.tokens[i - 1]
          end
        end

        def autocorrect(_node)
          lambda do |corrector|
            break_line_before_end(corrector)
            remove_semicolon(corrector)
          end
        end

        def break_line_before_end(corrector)
          corrector.insert_before(
            end_token.pos,
            "\n" + ' ' * configured_indentation_width
          )
        end

        def remove_semicolon(corrector)
          return unless token_before_end.type == :tSEMI
          corrector.remove(token_before_end.pos)
        end
      end
    end
  end
end
