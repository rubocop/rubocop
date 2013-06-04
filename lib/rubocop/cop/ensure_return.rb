# encoding: utf-8

module Rubocop
  module Cop
    class EnsureReturn < Cop
      MSG = 'Never return from an ensure block.'

      def on_ensure(node)
        _body, ensure_body = *node

        on_node(:return, ensure_body) do |e|
          add_offence(:warning, e.loc, MSG)
        end

        super
      end
    end
  end
end
