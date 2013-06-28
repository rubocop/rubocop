# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of Module#attr.
      class Attr < Cop
        MSG = 'Do not use `attr`. Use `attr_reader` instead.'

        def on_send(node)
          if command?(:attr, node)
            add_offence(:convention, node.loc.selector, MSG)
          end

          super
        end
      end
    end
  end
end
