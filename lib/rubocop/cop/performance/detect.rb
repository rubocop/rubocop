# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of
      # `select.first`, `select.last`, `find_all.first`, and `find_all.last`
      # and change them to use `detect` instead.
      #
      # @example
      #   # bad
      #   [].select { |item| true }.first
      #   [].select { |item| true }.last
      #   [].find_all { |item| true }.first
      #   [].find_all { |item| true }.last
      #
      #   # good
      #   [].detect { |item| true }
      #   [].reverse.detect { |item| true }
      #
      # `ActiveRecord` compatibility:
      # `ActiveRecord` does not implement a `detect` method and `find` has its
      # own meaning. Correcting ActiveRecord methods with this cop should be
      # considered unsafe.
      class Detect < Cop
        include SafeMode

        MSG = 'Use `%s` instead of `%s.%s`.'.freeze
        REVERSE_MSG = 'Use `reverse.%s` instead of `%s.%s`.'.freeze

        def_node_matcher :detect_candidate?, <<-PATTERN
          {
            (send $(block (send _ {:select :find_all}) ...) ${:first :last} $...)
            (send $(send _ {:select :find_all} ...) ${:first :last} $...)
          }
        PATTERN

        def on_send(node)
          return if rails_safe_mode?

          detect_candidate?(node) do |receiver, second_method, args|
            return unless args.empty?
            return unless receiver

            receiver, _args, body = *receiver if receiver.block_type?
            return if accept_first_call?(receiver, body)

            register_offense(node, receiver, second_method)
          end
        end

        def autocorrect(node)
          receiver, first_method = *node

          replacement = if first_method == :last
                          "reverse.#{preferred_method}"
                        else
                          preferred_method
                        end

          first_range = receiver.source_range.end.join(node.loc.selector)

          receiver, _args, _body = *receiver if receiver.block_type?

          lambda do |corrector|
            corrector.remove(first_range)
            corrector.replace(receiver.loc.selector, replacement)
          end
        end

        private

        def accept_first_call?(receiver, body)
          caller, _first_method, args = *receiver

          # check that we have usual block or block pass
          return true if body.nil? && (args.nil? || !args.block_pass_type?)

          lazy?(caller)
        end

        def register_offense(node, receiver, second_method)
          _caller, first_method, _args = *receiver
          range = receiver.loc.selector.join(node.loc.selector)

          message = second_method == :last ? REVERSE_MSG : MSG
          add_offense(node, range, format(message,
                                          preferred_method,
                                          first_method,
                                          second_method))
        end

        def preferred_method
          config.for_cop('Style/CollectionMethods') \
            ['PreferredMethods']['detect'] || 'detect'
        end

        def lazy?(node)
          return false if node.nil?
          receiver, method, _args = *node
          method == :lazy && !receiver.nil?
        end
      end
    end
  end
end
