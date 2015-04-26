# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of Module#attr.
      class Attr < Cop
        MSG = 'Do not use `attr`. Use `attr_reader` instead.'

        def on_send(node)
          return unless command?(:attr, node)
          _receiver, _method_name, *args = *node
          add_offense(node, :selector) if args.any?
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'attr_reader') }
        end
      end
    end
  end
end
