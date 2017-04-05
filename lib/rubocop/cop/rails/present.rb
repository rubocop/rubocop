# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cops checks for code that can be changed to `blank?`.
      # Settings:
      #   NotNilAndNotEmpty: Convert checks for not `nil` and `not empty?`
      #                      to `present?`
      #   NotBlank: Convert usages of not `blank?` to `present?`
      #   UnlessBlank: Convert usages of `unless` `blank?` to `if` `present?`
      #
      # @example
      #   # NotNilAndNotEmpty: true
      #     # bad
      #     !foo.nil? && !foo.empty?
      #     foo != nil && !foo.empty?
      #     !foo.blank?
      #
      #     # good
      #     foo.present?
      #
      #   # NotBlank: true
      #     # bad
      #     !foo.blank?
      #     not foo.blank?
      #
      #     # good
      #     foo.present?
      #
      #   # UnlessBlank: true
      #     # bad
      #     something unless foo.blank?
      #
      #     # good
      #     something if  foo.present?
      class Present < Cop
        MSG_NOT_BLANK = 'Use `%s` instead of `%s`.'.freeze
        MSG_EXISTS_AND_NOT_EMPTY = 'Use `%s.present?` instead of `%s`.'.freeze
        MSG_UNLESS_BLANK = 'Use `if %s.present?` instead of `%s`.'.freeze

        def_node_matcher :exists_and_not_empty?, <<-PATTERN
          (and
              {
                (send (send $_ :nil?) :!)
                (send (send $_ :!) :!)
                (send $_ :!= (:nil))
                $_
              }
              {
                (send (send $_ :empty?) :!)
              }
          )
        PATTERN

        def_node_matcher :not_blank?, '(send (send $_ :blank?) :!)'

        def_node_matcher :unless_blank?, <<-PATTERN
          (:if $(send $_ :blank?) {nil (...)} ...)
        PATTERN

        def on_send(node)
          return unless cop_config['NotBlank']

          not_blank?(node) do |receiver|
            add_offense(node,
                        :expression,
                        format(MSG_NOT_BLANK,
                               replacement(receiver),
                               node.source))
          end
        end

        def on_and(node)
          return unless cop_config['NotNilAndNotEmpty']

          exists_and_not_empty?(node) do |variable1, variable2|
            return unless variable1 == variable2

            add_offense(node,
                        :expression,
                        format(MSG_EXISTS_AND_NOT_EMPTY,
                               variable1.source,
                               node.source))
          end
        end

        def on_or(node)
          return unless cop_config['NilOrEmpty']

          exists_and_not_empty?(node) do |variable1, variable2|
            return unless variable1 == variable2

            add_offense(node, :expression, MSG_EXISTS_AND_NOT_EMPTY)
          end
        end

        def on_if(node)
          return unless cop_config['UnlessBlank']
          return unless node.unless?

          unless_blank?(node) do |method_call, receiver|
            range = unless_condition(node, method_call)
            add_offense(node,
                        range,
                        format(MSG_UNLESS_BLANK, receiver.source, range.source))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            method_call, variable1 = unless_blank?(node)

            if method_call && variable1
              corrector.replace(node.loc.keyword, 'if')
              range = method_call.loc.expression
            else
              variable1, _variable2 =
                exists_and_not_empty?(node) || not_blank?(node)
              range = node.loc.expression
            end

            corrector.replace(range, replacement(variable1))
          end
        end

        private

        def unless_condition(node, method_call)
          if node.modifier_form?
            node.loc.keyword.join(node.loc.expression.end)
          else
            node.loc.expression.begin.join(method_call.loc.expression)
          end
        end

        def replacement(node)
          node.respond_to?(:source) ? "#{node.source}.present?" : 'present?'
        end
      end
    end
  end
end
