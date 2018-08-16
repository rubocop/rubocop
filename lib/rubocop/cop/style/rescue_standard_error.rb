# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for rescuing `StandardError`. There are two supported
      # styles `implicit` and `explicit`. This cop will not register an offense
      # if any error other than `StandardError` is specified.
      #
      # @example EnforcedStyle: implicit
      #   # `implicit` will enforce using `rescue` instead of
      #   # `rescue StandardError`.
      #
      #   # bad
      #   begin
      #     foo
      #   rescue StandardError
      #     bar
      #   end
      #
      #   # good
      #   begin
      #     foo
      #   rescue
      #     bar
      #   end
      #
      #   # good
      #   begin
      #     foo
      #   rescue OtherError
      #     bar
      #   end
      #
      #   # good
      #   begin
      #     foo
      #   rescue StandardError, SecurityError
      #     bar
      #   end
      #
      # @example EnforcedStyle: explicit (default)
      #   # `explicit` will enforce using `rescue StandardError`
      #   # instead of `rescue`.
      #
      #   # bad
      #   begin
      #     foo
      #   rescue
      #     bar
      #   end
      #
      #   # good
      #   begin
      #     foo
      #   rescue StandardError
      #     bar
      #   end
      #
      #   # good
      #   begin
      #     foo
      #   rescue OtherError
      #     bar
      #   end
      #
      #   # good
      #   begin
      #     foo
      #   rescue StandardError, SecurityError
      #     bar
      #   end
      class RescueStandardError < Cop
        include RescueNode
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_IMPLICIT = 'Omit the error class when rescuing ' \
          '`StandardError` by itself.'.freeze
        MSG_EXPLICIT = 'Avoid rescuing without specifying ' \
          'an error class.'.freeze

        def_node_matcher :rescue_without_error_class?, <<-PATTERN
          (resbody nil? _ _)
        PATTERN

        def_node_matcher :rescue_standard_error?, <<-PATTERN
          (resbody $(array (const nil? :StandardError)) _ _)
        PATTERN

        def on_resbody(node)
          return if rescue_modifier?(node)

          case style
          when :implicit
            rescue_standard_error?(node) do |error|
              add_offense(node,
                          location: node.loc.keyword.join(error.loc.expression),
                          message: MSG_IMPLICIT)
            end
          when :explicit
            rescue_without_error_class?(node) do
              add_offense(node, location: :keyword, message: MSG_EXPLICIT)
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            case style
            when :implicit
              error = rescue_standard_error?(node)
              range = range_between(node.loc.keyword.end_pos,
                                    error.loc.expression.end_pos)
              corrector.remove(range)
            when :explicit
              corrector.insert_after(node.loc.keyword, ' StandardError')
            end
          end
        end
      end
    end
  end
end
