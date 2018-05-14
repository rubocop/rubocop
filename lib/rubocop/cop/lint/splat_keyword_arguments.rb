# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      #
      # This cop emulates the following Ruby warnings in Ruby 2.6.
      #
      # % ruby -we "def m(a) end; h = {foo: 1}; m(**h)"
      # -e:1: warning: passing splat keyword arguments as a single Hash to `m'
      #
      # It checks for use of splat keyword arguments as a single Hash.
      #
      # @example
      #   # bad
      #   do_something(**arguments)
      #
      #   # good
      #   do_something(arguments)
      #
      class SplatKeywordArguments < Cop
        MSG = 'Do not use splat keyword arguments as a single Hash.'.freeze

        def on_send(node)
          node.arguments.each do |argument|
            next unless argument.hash_type?

            argument.children.each do |element|
              add_offense(element) if element.kwsplat_type?
            end
          end
        end
      end
    end
  end
end
