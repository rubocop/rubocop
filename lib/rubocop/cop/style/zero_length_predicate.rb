# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for receiver.length == 0 predicates and the
      # negated versions receiver.length > 0 and receiver.length != 0.
      # These can be replaced with receiver.empty? and
      # !receiver.empty? respectively.
      #
      # @example
      #
      #   @bad
      #   [1, 2, 3].length == 0
      #   0 == "foobar".length
      #   hash.size > 0
      #
      #   @good
      #   [1, 2, 3].empty?
      #   "foobar".empty?
      #   !hash.empty?
      class ZeroLengthPredicate < Cop
        ZERO_MSG = 'Use `empty?` instead of `%s %s %s`.'.freeze
        NONZERO_MSG = 'Use `!empty?` instead of `%s %s %s`.'.freeze

        def on_send(node)
          zero_length_predicate = zero_length_predicate(node)

          if zero_length_predicate
            add_offense(node, :expression,
                        format(ZERO_MSG, *zero_length_predicate))
          end

          nonzero_length_predicate = nonzero_length_predicate(node)

          # rubocop:disable Style/GuardClause
          if nonzero_length_predicate
            add_offense(node, :expression,
                        format(NONZERO_MSG, *nonzero_length_predicate))
          end
          # rubocop:enable Style/GuardClause
        end

        def_node_matcher :zero_length_predicate, <<-END
          {(send (send (...) ${:length :size}) $:== (int $0))
           (send (int $0) $:== (send (...) ${:length :size}))
           (send (send (...) ${:length :size}) $:<  (int $1))
           (send (int $1) $:> (send (...) ${:length :size}))}
        END

        def_node_matcher :nonzero_length_predicate, <<-END
          {(send (send (...) ${:length :size}) ${:> :!=} (int $0))
           (send (int $0) ${:< :!=} (send (...) ${:length :size}))}
        END

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, replacement(node))
          end
        end

        def replacement(node)
          receiver = zero_length_receiver(node)
          return "#{receiver.source}.empty?" if receiver

          "!#{other_receiver(node).source}.empty?"
        end

        def_node_matcher :zero_length_receiver, <<-END
          {(send (send $_ _) :== (int 0))
           (send (int 0) :== (send $_ _))
           (send (send $_ _) :<  (int 1))
           (send (int 1) :> (send $_ _))}
        END

        def_node_matcher :other_receiver, <<-END
          {(send (send $_ _) _ _)
           (send _ _ (send $_ _))}
        END
      end
    end
  end
end
