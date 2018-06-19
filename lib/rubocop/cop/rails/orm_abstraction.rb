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
          (pair {str_type? sym_type? dstr_type?} (send !nil? {:id :uuid}))
        PATTERN

        def on_pair(node)
          return unless bad_pair?(node)
          return if !node.key.source.match(BAD_RXP)

          corrector = Corrector.new(processed_source.buffer)
          replacement = prefered_pair(node, corrector)
            .process_node(node.loc.expression)

          add_offense(
            node,
            location: node.loc.expression,
            message: "prefer `#{replacement}`."
          )
        end

        BAD_RXP = /_(id|uuid)(?="|'|$)/

        def autocorrect(node)
          lambda do |corrector|
            prefered_pair(node, corrector)
          end
        end

        def prefered_pair(bad_pair, corrector)
          key, val = bad_pair.to_a
          prefered_key(key, corrector)
          prefered_val(val, corrector)
        end

        def prefered_key(key, corrector)
          corrector.replace(key.loc.expression, key.source.sub(BAD_RXP, ''))
        end

        def prefered_val(val, corrector)
          corrector.replace(val.loc.expression, val.receiver.source)
        end
      end
    end
  end
end

class Parser::Source::TreeRewriter
  def process_node(node_range)
    source     = @source_buffer.source.dup
    adjustment = 0
    @action_root.ordered_replacements.each do |range, replacement|
      next if !node_range.contains?(range)
      begin_pos = range.begin_pos + adjustment
      end_pos   = begin_pos + range.length

      source[begin_pos...end_pos] = replacement

      adjustment += replacement.length - range.length
    end
    source[node_range.begin_pos...(node_range.end_pos + adjustment)]
  end
end
