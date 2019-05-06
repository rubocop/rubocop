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
        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'

        def_node_matcher :redundant_receiver_and_other, <<-PATTERN
          {
            (if
              (send $_recv :present?)
              _recv
              $!begin
            )
            (if
              (send $_recv :blank?)
              $!begin
              _recv
            )
          }
        PATTERN

        def_node_matcher :redundant_negative_receiver_and_other, <<-PATTERN
          {
            (if
              (send (send $_recv :present?) :!)
              $!begin
              _recv
            )
            (if
              (send (send $_recv :blank?) :!)
              _recv
              $!begin
            )
          }
        PATTERN

        def on_if(node)
          return if ignore_if_node?(node)

          redundant_receiver_and_other(node) do |receiver, other|
            unless ignore_other_node?(other) || receiver.nil?
              add_offense(node, message: message(node, receiver, other))
            end
          end

          redundant_negative_receiver_and_other(node) do |receiver, other|
            unless ignore_other_node?(other) || receiver.nil?
              add_offense(node, message: message(node, receiver, other))
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            redundant_receiver_and_other(node) do |receiver, other|
              corrector.replace(node.source_range, replacement(receiver, other))
            end

            redundant_negative_receiver_and_other(node) do |receiver, other|
              corrector.replace(node.source_range, replacement(receiver, other))
            end
          end
        end

        private

        def ignore_if_node?(node)
          node.elsif?
        end

        def ignore_other_node?(node)
          node && (node.if_type? || node.rescue_type? || node.while_type?)
        end

        def message(node, receiver, other)
          format(MSG,
                 prefer: replacement(receiver, other),
                 current: node.source)
        end

        def replacement(receiver, other)
          or_source = other.nil? || other.nil_type? ? '' : " || #{other.source}"
          "#{receiver.source}.presence" + or_source
        end
      end
    end
  end
end
