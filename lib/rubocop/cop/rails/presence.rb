# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks code that can be written more easily using
      # `Object#presence` defined by Active Support.
      #
      # @example
      #   # bad
      #   a.present? ? a : nil
      #
      #   # bad
      #   !a.present? ? nil : a
      #
      #   # bad
      #   a.blank? ? nil : a
      #
      #   # bad
      #   !a.blank? ? a : nil
      #
      #   # good
      #   a.presence
      #
      # @example
      #   # bad
      #   a.present? ? a : b
      #
      #   # bad
      #   !a.present? ? b : a
      #
      #   # bad
      #   a.blank? ? b : a
      #
      #   # bad
      #   !a.blank? ? a : b
      #
      #   # good
      #   a.presence || b
      class Presence < Cop
        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'.freeze

        def_node_matcher :redundant_receiver_and_other, <<-PATTERN
          {
            (if
              (send $_recv :present?)
              _recv
              $_false
            )
            (if
              (send $_recv :blank?)
              $_true
              _recv
            )
          }
        PATTERN

        def_node_matcher :redundant_negative_receiver_and_other, <<-PATTERN
          {
            (if
              (send (send $_recv :present?) :!)
              $_true
              _recv
            )
            (if
              (send (send $_recv :blank?) :!)
              _recv
              $_false
            )
          }
        PATTERN

        def on_if(node)
          receiver, other = redundant_receiver_and_other(node)
          unless receiver
            receiver, other = redundant_negative_receiver_and_other(node)
          end
          return unless receiver
          message = format(MSG,
                           prefer: replacement(receiver, other),
                           current: node.source)
          add_offense(node, message: message)
        end

        def autocorrect(node)
          lambda do |corrector|
            receiver, other = redundant_receiver_and_other(node)
            unless receiver
              receiver, other = redundant_negative_receiver_and_other(node)
            end
            return unless receiver
            corrector.replace(node.source_range, replacement(receiver, other))
          end
        end

        private

        def replacement(receiver, other)
          or_source = other.nil_type? ? '' : " || #{other.source}"
          "#{receiver.source}.presence" + or_source
        end
      end
    end
  end
end
