# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for interpolated literals.
      #
      # @example
      #
      #   "result is #{10}"
      class LiteralInInterpolation < Cop
        LITERALS = [:str, :dstr, :int, :float, :array,
                    :hash, :regexp, :nil, :true, :false]

        MSG = 'Literal interpolation detected.'

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
            final_node = begin_node.children.last
            next unless LITERALS.include?(final_node.type)

            add_offense(final_node, :expression)
          end
        end
      end
    end
  end
end
