# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Avoid breaking ORM abstraction.
      # @example
      #
      #   # bad
      #   where(foo_id: foo.id)
      #
      #   # bad
      #   create(foo_id: foo.id)
      #
      #   # good
      #   where(foo: foo)
      #
      #   # good
      #   create(foo: foo)

      class ORMAbstraction < Cop
        def_node_matcher :bad_pair?, <<-PATTERN
          (pair _ (send !nil? {:id :uuid}))
        PATTERN

        def on_pair(node)
          return unless bad_pair?(node)
          return unless node.key.source.match(BAD_RXP)

          add_offense(
            node,
            location: node.loc.expression,
            message: "prefer `#{prefered_pair(node)}`."
          )
        end

        BAD_RXP = /(_id|_uuid)(:|'|"|\s|$)/

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, prefered_pair(node))
          end
        end

        def prefered_pair(bad_pair)
          key, val = bad_pair.to_a
          bad_pair.source.sub(key.source, key.source.sub(BAD_RXP, '\2')).sub(val.source, val.receiver.source)
        end
      end
    end
  end
end
