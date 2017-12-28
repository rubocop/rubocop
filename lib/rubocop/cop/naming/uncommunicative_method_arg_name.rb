# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure method argument names meet a configurable
      # level of description
      # @example
      #   # bad
      #   def foo(num1, num2)
      #     num1 + num2
      #   end
      #
      #   def bar(varOne, varTwo)
      #     varOne + varTwo
      #   end
      #
      #   # With `MinArgNameLength` set to number greater than 1
      #   def baz(x, y, z)
      #     do_stuff(x, y, z)
      #   end
      #
      #   # good
      #   def foo(first_num, second_num)
      #     first_num + second_num
      #   end
      #
      #   def bar(var_one, var_two)
      #     var_one + var_two
      #   end
      #
      #   def baz(age_x, height_y, gender_z)
      #     do_stuff(age_x, height_y, gender_z)
      #   end
      class UncommunicativeMethodArgName < Cop
        include UncommunicativeName

        def on_def(node)
          return unless node.arguments?
          check(node, node.arguments)
        end
        alias on_defs on_def
      end
    end
  end
end
