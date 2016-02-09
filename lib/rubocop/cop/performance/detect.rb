# encoding: utf-8
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
      class Detect < Cop
        MSG = 'Use `%s` instead of `%s.%s`.'.freeze
        REVERSE_MSG = 'Use `reverse.%s` instead of `%s.%s`.'.freeze

        SELECT_METHODS = [:select, :find_all].freeze
        DANGEROUS_METHODS = [:first, :last].freeze

        def on_send(node)
          receiver, second_method, *args = *node
          return unless check_second_call(receiver, second_method, args)

          receiver, _args, body = *receiver if receiver.block_type?
          caller, first_method, args = *receiver

          # check that we have usual block or block pass
          return if body.nil? && (args.nil? || !args.block_pass_type?)
          return unless SELECT_METHODS.include?(first_method)
          return if lazy?(caller)

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

          first_range = receiver.source_range.end.join(node.loc.selector)

          receiver, _args, _body = *receiver if receiver.block_type?

          lambda do |corrector|
            corrector.remove(first_range)
            corrector.replace(receiver.loc.selector, replacement)
          end
        end

        private

        def check_second_call(receiver, method, args)
          receiver &&
            DANGEROUS_METHODS.include?(method) &&
            args.empty?
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
