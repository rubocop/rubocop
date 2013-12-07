# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of Module#attr.
      class Attr < Cop
        MSG = 'Do not use `attr`. Use `attr_reader` instead.'

        def on_send(node)
          add_offence(node, :selector) if command?(:attr, node)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.selector, 'attr_reader')
          end
        end
      end
    end
  end
end
