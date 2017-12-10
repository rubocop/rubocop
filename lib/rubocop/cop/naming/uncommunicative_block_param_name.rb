# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure block parameter names meet a configurable
      # level of description
      #
      # @example
      #   # bad
      #   foo { |num1, num2| num1 + num2 }
      #
      #   bar do |varOne, varTwo|
      #     varOne + varTwo
      #   end
      #
      #   # With `MinParamNameLength` set to number greater than 1
      #   baz { |x, y, z| do_stuff(x, y, z) }
      #
      #   # good
      #   foo { |first_num, second_num| first_num + second_num }
      #
      #   bar do |var_one, var_two|
      #     var_one + var_two
      #   end
      #
      #   baz { |age, height, gender| do_stuff(age, height, gender) }
      class UncommunicativeBlockParamName < Cop
        include UncommunicativeName

        def on_block(node)
          return unless node.arguments?
          check(node, node.arguments, min: min_length)
        end

        private

        def min_length
          cop_config['MinParamNameLength']
        end
      end
    end
  end
end
