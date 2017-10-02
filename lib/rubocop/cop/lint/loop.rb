# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of *begin...end while/until something*.
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
      #   # using while
      #   while some_condition
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   # using until
      #   until some_condition
      #     do_something
      #   end
      class Loop < Cop
        MSG = 'Use `Kernel#loop` with `break` rather than ' \
              '`begin/end/until`(or `while`).'.freeze

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
