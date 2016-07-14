# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for definition of method_missing.
      #
      # @example
      #   #bad
      #   def method_missing ...
      #
      #   #good
      #   def delegation ...
      #   def proxy ...
      #   def define_method ...
      #
      #   #good
      #   if you must use method_missing be sure to define respond_to_missing?
      #   def method_missing ...
      #   def respond_to_missing? ...
      class MethodMissing < Cop
        include OnMethodDef

        MSG = 'Avoid using `method_missing`. Instead use `delegation`, '\
              '`proxy` or `define_method`.'.freeze

        def on_method_def(node, method_name, _args, _body)
          lvar_node = node.each_descendant.find(&:lvar_type?)

          if method_name == :method_missing
            return if lvar_node.to_a == [:formatter]
            add_offense(node, :expression)
          end
        end
      end
    end
  end
end
