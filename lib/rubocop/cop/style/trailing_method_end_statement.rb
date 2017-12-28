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
        include Alignment

        MSG = 'Place the end statement of a multi-line method on ' \
              'its own line.'.freeze

        def on_def(node)
          return unless trailing_end?(node)

          add_offense(node.to_a.last, location: end_token(node).pos)
        end

        def autocorrect(node)
          lambda do |corrector|
            break_line_before_end(node, corrector)
            remove_semicolon(node, corrector)
          end
        end

        private

        def trailing_end?(node)
          node.body &&
            node.multiline? &&
            body_and_end_on_same_line?(node)
        end

        def end_token(node)
          @end_token ||= tokens(node).reverse.find(&:end?)
        end

        def body_and_end_on_same_line?(node)
          end_token(node).line == token_before_end(node).line
        end

        def token_before_end(node)
          @token_before_end ||= begin
            i = tokens(node).index(end_token(node))
            tokens(node)[i - 1]
          end
        end

        def break_line_before_end(node, corrector)
          corrector.insert_before(
            end_token(node).pos,
            "\n" + ' ' * configured_indentation_width
          )
        end

        def remove_semicolon(node, corrector)
          return unless token_before_end(node).semicolon?
          corrector.remove(token_before_end(node).pos)
        end
      end
    end
  end
end
