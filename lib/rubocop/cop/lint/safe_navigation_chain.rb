# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # The safe navigation operator returns nil if the receiver is
      # nil. If you chain an ordinary method call after a safe
      # navigation operator, it raises NoMethodError. We should use a
      # safe navigation operator after a safe navigation operator.
      # This cop checks for the problem outlined above.
      #
      # @example
      #
      #   # bad
      #
      #   x&.foo.bar
      #   x&.foo + bar
      #   x&.foo[bar]
      #
      # @example
      #
      #   # good
      #
      #   x&.foo&.bar
      #   x&.foo || bar
      class SafeNavigationChain < Base
        include NilMethods
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.3

        MSG = 'Do not chain ordinary method call after safe navigation operator.'
        PLUS_MINUS_METHODS = %i[+@ -@].freeze

        # @!method bad_method?(node)
        def_node_matcher :bad_method?, <<~PATTERN
          {
            (send $(csend ...) $_ ...)
            (send $({block numblock} (csend ...) ...) $_ ...)
          }
        PATTERN

        def on_send(node)
          bad_method?(node) do |safe_nav, method|
            return if nil_methods.include?(method) || PLUS_MINUS_METHODS.include?(node.method_name)

            method_chain = method_chain(node)
            location =
              Parser::Source::Range.new(node.source_range.source_buffer,
                                        safe_nav.source_range.end_pos,
                                        method_chain.source_range.end_pos)
            add_offense(location) do |corrector|
              autocorrect(corrector, offense_range: location, send_node: method_chain)
            end
          end
        end

        private

        # @param [Parser::Source::Range] offense_range
        # @param [RuboCop::AST::SendNode] send_node
        # @return [String]
        def add_safe_navigation_operator(offense_range:, send_node:)
          source =
            if (brackets = find_brackets(send_node))
              format(
                '%<method_name>s(%<arguments>s)%<method_chain>s',
                arguments: brackets.arguments.map(&:source).join(', '),
                method_name: brackets.method_name,
                method_chain: brackets.source_range.end.join(send_node.source_range.end).source
              )
            else
              offense_range.source
            end
          source.prepend('.') unless source.start_with?('.')
          source.prepend('&')
        end

        # @param [RuboCop::Cop::Corrector] corrector
        # @param [Parser::Source::Range] offense_range
        # @param [RuboCop::AST::SendNode] send_node
        def autocorrect(corrector, offense_range:, send_node:)
          corrector.replace(
            offense_range,
            add_safe_navigation_operator(
              offense_range: offense_range,
              send_node: send_node
            )
          )
        end

        def method_chain(node)
          chain = node
          chain = chain.parent if chain.send_type? && chain.parent&.call_type?
          chain
        end

        def find_brackets(send_node)
          return send_node if send_node.method?(:[]) || send_node.method?(:[]=)

          send_node.descendants.detect do |node|
            node.send_type? && (node.method?(:[]) || node.method?(:[]=))
          end
        end
      end
    end
  end
end
