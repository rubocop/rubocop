# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for circular argument references in optional keyword
      # arguments and optional ordinal arguments.
      #
      # This cop mirrors a warning produced by MRI since 2.2.
      #
      # @example
      #
      #   # bad
      #
      #   def bake(pie: pie)
      #     pie.heat_up
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def bake(pie:)
      #     pie.refrigerate
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def bake(pie: self.pie)
      #     pie.feed_to(user)
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   def cook(dry_ingredients = dry_ingredients)
      #     dry_ingredients.reduce(&:+)
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def cook(dry_ingredients = self.dry_ingredients)
      #     dry_ingredients.combine
      #   end
      class CircularArgumentReference < Cop
        MSG = 'Circular argument reference - `%s`.'.freeze

        def on_kwoptarg(node)
          check_for_circular_argument_references(*node)
        end

        def on_optarg(node)
          check_for_circular_argument_references(*node)
        end

        private

        def check_for_circular_argument_references(arg_name, arg_value)
          case arg_value.type
          when :send
            # Ruby 2.0 will have type send every time, and "send nil" if it is
            # calling itself with a specified "self" receiver
            receiver, name = *arg_value
            return unless name == arg_name && receiver.nil?
          when :lvar
            # Ruby 2.2.2 will have type lvar if it is calling its own method
            # without a specified "self"
            return unless arg_value.to_a == [arg_name]
          else
            return
          end

          add_offense(arg_value, :expression, format(MSG, arg_name))
        end
      end
    end
  end
end
