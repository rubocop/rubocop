# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for string conversion in string interpolation,
      # which is redundant.
      #
      # @example
      #
      #   "result is #{something.to_s}"
      class StringConversionInInterpolation < Cop
        MSG = 'Redundant use of Object#to_s in interpolation.'

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            final_node = begin_node.children.last
            next unless final_node.type == :send

            _receiver, method_name, *args = *final_node

            if method_name == :to_s && args.empty?
              add_offense(final_node, :selector)
            end
          end
        end
      end
    end
  end
end
