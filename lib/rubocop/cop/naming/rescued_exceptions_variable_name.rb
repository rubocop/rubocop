# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that rescued exceptions variables are named as
      # expected.
      #
      # The `PreferredName` config option takes a `String`. It represents
      # the required name of the variable. Its default is `e`.
      #
      # @example PreferredName: e (default)
      #   # bad
      #   begin
      #     # do something
      #   rescue MyException => exception
      #     # do something
      #   end
      #
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => e
      #     # do something
      #   end
      #
      # @example PreferredName: exception
      #   # bad
      #   begin
      #     # do something
      #   rescue MyException => e
      #     # do something
      #   end
      #
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => exception
      #     # do something
      #   end
      #
      class RescuedExceptionsVariableName < Cop
        MSG = 'Use `%<preferred>s` instead of `%<bad>s`.'.freeze

        def on_resbody(node)
          exception_type, @exception_name = *node
          return unless exception_type || @exception_name

          @exception_name ||= exception_type.children.first
          return if @exception_name.const_type? ||
                    variable_name == preferred_name

          add_offense(node, location: location)
        end

        private

        def preferred_name
          @preferred_name ||= cop_config.fetch('PreferredName', 'e')
        end

        def variable_name
          @variable_name ||= location.source
        end

        def location
          @location ||= @exception_name.loc.expression
        end

        def message(_node = nil)
          format(MSG, preferred: preferred_name, bad: variable_name)
        end
      end
    end
  end
end
