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
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => _e
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
      #   # good
      #   begin
      #     # do something
      #   rescue MyException => _exception
      #     # do something
      #   end
      #
      class RescuedExceptionsVariableName < Base
        extend AutoCorrector

        MSG = 'Use `%<preferred>s` instead of `%<bad>s`.'

        def on_resbody(node)
          offending_name = variable_name(node)
          return unless offending_name

          preferred_name = preferred_name(offending_name)
          return if preferred_name.to_sym == offending_name

          range = offense_range(node)
          message = message(node)

          add_offense(range, message: message) do |corrector|
            corrector.replace(range, preferred_name)

            node.body&.each_descendant(:lvar) do |var|
              next unless var.children.first == offending_name

              corrector.replace(var, preferred_name)
            end
          end
        end

        private

        def offense_range(resbody)
          variable = resbody.exception_variable
          variable.loc.expression
        end

        def preferred_name(variable_name)
          preferred_name = cop_config.fetch('PreferredName', 'e')
          if variable_name.to_s.start_with?('_')
            "_#{preferred_name}"
          else
            preferred_name
          end
        end

        def variable_name(node)
          asgn_node = node.exception_variable
          return unless asgn_node

          asgn_node.children.last
        end

        def message(node)
          offending_name = variable_name(node)
          preferred_name = preferred_name(offending_name)
          format(MSG, preferred: preferred_name, bad: offending_name)
        end
      end
    end
  end
end
