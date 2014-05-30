# encoding: utf-8

module RuboCop
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
            next unless final_node
            # handle strings like __FILE__
            return if special_string?(final_node)
            next unless LITERALS.include?(final_node.type)

            add_offense(final_node, :expression)
          end
        end

        private

        def special_string?(node)
          node.type == :str && !node.loc.respond_to?(:begin)
        end
      end
    end
  end
end
