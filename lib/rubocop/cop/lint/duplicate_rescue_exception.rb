# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks that there are no repeated exceptions
      # used in 'rescue' expressions.
      #
      # @example
      #   # bad
      #   begin
      #     something
      #   rescue FirstException
      #     handle_exception
      #   rescue FirstException
      #     handle_other_exception
      #   end
      #
      #   # good
      #   begin
      #     something
      #   rescue FirstException
      #     handle_exception
      #   rescue SecondException
      #     handle_other_exception
      #   end
      #
      class DuplicateRescueException < Base
        include RescueNode

        MSG = 'Duplicate `rescue` exception detected.'

        def on_rescue(node)
          return if rescue_modifier?(node)

          _body, *resbodies, _else = *node

          resbodies.each_with_object(Set.new) do |resbody, previous|
            rescued_exceptions = rescued_exceptions(resbody)

            rescued_exceptions.each do |exception|
              add_offense(exception) unless previous.add?(exception)
            end
          end
        end

        private

        def rescued_exceptions(resbody)
          rescue_group, = *resbody
          if rescue_group
            rescue_group.values
          else
            []
          end
        end
      end
    end
  end
end
