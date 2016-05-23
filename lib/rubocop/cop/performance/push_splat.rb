# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of
      #
      # @example
      #   # bad
      #   [].push(*a)
      #
      #   # good
      #   [].concat(a)
      class PushSplat < Cop
        include Parentheses

        MSG = 'Use `concat` instead of `push(*)`.'.freeze

        def_node_matcher :push_splat, <<-END
          (send _ :push (splat ...))
        END

        def on_send(node)
          push_splat(node) do
            add_offense(node, :expression, MSG)
          end
        end

        def autocorrect(node)
          _receiver, _method, splat = *node
          body, = *splat
          lambda do |corrector|
            corrector.replace(node.location.selector, 'concat')

            source = if parens_required?(splat)
                       "(#{body.source})"
                     else
                       body.source
                     end
            corrector.replace(splat.loc.expression, source)
          end
        end
      end
    end
  end
end
