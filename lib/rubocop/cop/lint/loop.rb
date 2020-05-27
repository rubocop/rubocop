# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of `begin...end while/until something`.
      #
      # @example
      #
      #   # bad
      #
      #   # using while
      #   begin
      #     do_something
      #   end while some_condition
      #
      # @example
      #
      #   # bad
      #
      #   # using until
      #   begin
      #     do_something
      #   end until some_condition
      #
      # @example
      #
      #   # good
      #
      #   # while replacement
      #   loop do
      #     do_something
      #     break unless some_condition
      #   end
      #
      # @example
      #
      #   # good
      #
      #   # until replacement
      #   loop do
      #     do_something
      #     break if some_condition
      #   end
      class Loop < Cop
        MSG = 'Use `Kernel#loop` with `break` rather than ' \
              '`begin/end/until`(or `while`).'

        def on_while_post(node)
          register_offense(node)
        end

        def on_until_post(node)
          register_offense(node)
        end

        private

        def register_offense(node)
          add_offense(node, location: :keyword)
        end
      end
    end
  end
end
