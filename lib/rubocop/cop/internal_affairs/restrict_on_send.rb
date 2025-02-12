# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Check for missing `RESTRICT_ON_SEND`.
      #
      # @example
      #   # bad
      #   class FooCop
      #     def on_send(node)
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class FooCop
      #     RESTRICT_ON_SEND = %i[bad_method].freeze
      #     def on_send(node)
      #       # ...
      #     end
      #   end
      #
      class RestrictOnSend < Base
        MSG = 'Missing `RESTRICT_ON_SEND` declaration when using `on_send` or `after_send`.'

        # @!method defined_send_callback?(node)
        def_node_search :defined_send_callback?, <<~PATTERN
          {
            (def {:on_send :after_send} ...)
            (alias (sym {:on_send :after_send}) _source ...)
            (send nil? :alias_method {(sym {:on_send :after_send}) (str {"on_send" "after_send"})} _source ...)
          }
        PATTERN

        # @!method restrict_on_send?(node)
        def_node_search :restrict_on_send?, <<~PATTERN
          (casgn nil? :RESTRICT_ON_SEND ...)
        PATTERN

        # from: https://github.com/rubocop/rubocop/blob/e78790e3c9e82f8e605009673a8d2eac40b18c4c/lib/rubocop/cop/internal_affairs/undefined_config.rb#L25
        # @!method cop_class_def(node)
        def_node_matcher :cop_class_def, <<~PATTERN
          (class _
            (const {nil? (const nil? :Cop) (const (const {cbase nil?} :RuboCop) :Cop)}
              {:Base :Cop}) ...)
        PATTERN

        def on_class(node)
          return if restrict_on_send?(node) # requirement met

          return unless defined_send_callback?(node)
          return unless cop_class_def(node)

          add_offense(node)
        end
      end
    end
  end
end
