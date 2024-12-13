# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for assigning raised exception with writer method.
      #
      # @example
      #   # bad
      #   begin
      #     do_something
      #    rescue StandardError => foo.exception
      #    end
      #
      #   # good
      #   begin
      #     do_something
      #    rescue StandardError => e
      #      foo.exception = e
      #    end
      class RescueVariableWriter < Base
        MSG = 'Do not use writer method for rescued exception.'

        def on_resbody(node)
          return unless node.exception_variable&.send_type?

          add_offense(node.exception_variable)
        end
      end
    end
  end
end
