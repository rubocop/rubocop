# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for *rescue* blocks with no body.
      #
      # @example
      #
      #   # bad
      #
      #   def some_method
      #     do_something
      #   rescue
      #     # do nothing
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   begin
      #     do_something
      #   rescue
      #     # do nothing
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     do_something
      #   rescue
      #     handle_exception
      #   end
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     do_something
      #   rescue
      #     handle_exception
      #   end
      class HandleExceptions < Cop
        MSG = 'Do not suppress exceptions.'.freeze

        def on_resbody(node)
          _exc_list_node, _exc_var_node, body_node = *node

          add_offense(node, :expression) unless body_node
        end
      end
    end
  end
end
