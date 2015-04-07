# encoding: utf-8

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
      class Detect < Cop
        MSG = 'Use `%s` instead of `%s.%s`.'
        REVERSE_MSG = 'Use `reverse.%s` instead of `%s.%s`.'

        SELECT_METHODS = [:select, :find_all]

        def on_send(node)
          receiver, second_method = *node
          return unless second_method == :first || second_method == :last
          return if receiver.nil?

          receiver, _args, body = *receiver if receiver.block_type?

          _, first_method, args = *receiver

          # check that we have usual block or block pass
          return if body.nil? && (args.nil? || !args.block_pass_type?)

          return unless SELECT_METHODS.include?(first_method)

          range = receiver.loc.selector.join(node.loc.selector)

          message = second_method == :last ? REVERSE_MSG : MSG
          add_offense(node, range, format(message,
                                          preferred_method,
                                          first_method,
                                          second_method))
        end

        def autocorrect(node)
          receiver, first_method = *node

          replacement = if first_method == :last
                          "reverse.#{preferred_method}"
                        else
                          preferred_method
                        end
          first_range = node.loc.dot.join(node.loc.selector)

          receiver, _args, _body = *receiver if receiver.block_type?

          @corrections << lambda do |corrector|
            corrector.remove(first_range)
            corrector.replace(receiver.loc.selector, replacement)
          end
        end

        private

        def preferred_method
          config.for_cop('Style/CollectionMethods') \
            ['PreferredMethods']['detect'] || 'detect'
        end
      end
    end
  end
end
