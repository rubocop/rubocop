# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for using Fixnum or Bignum constant.
      #
      # @example
      #
      #   # bad
      #
      #   1.is_a?(Fixnum)
      #   1.is_a?(Bignum)
      #
      # @example
      #
      #   # good
      #
      #   1.is_a?(Integer)
      class UnifiedInteger < Cop
        MSG = 'Use `Integer` instead of `%s`.'.freeze

        def_node_matcher :fixnum_or_bignum_const, <<-PATTERN
          (:const {nil? (:cbase)} ${:Fixnum :Bignum})
        PATTERN

        def on_const(node)
          klass = fixnum_or_bignum_const(node)

          return unless klass

          add_offense(node, message: format(MSG, klass))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.name, 'Integer')
          end
        end
      end
    end
  end
end
