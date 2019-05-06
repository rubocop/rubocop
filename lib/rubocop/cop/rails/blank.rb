# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for code that can be written with simpler conditionals
      # using `Object#blank?` defined by Active Support.
      #
      # Interaction with `Style/UnlessElse`:
      # The configuration of `NotPresent` will not produce an offense in the
      # context of `unless else` if `Style/UnlessElse` is inabled. This is
      # to prevent interference between the auto-correction of the two cops.
      #
      # @example NilOrEmpty: true (default)
      #   # Converts usages of `nil? || empty?` to `blank?`
      #
      #   # bad
      #   foo.nil? || foo.empty?
      #   foo == nil || foo.empty?
      #
      #   # good
      #   foo.blank?
      #
      # @example NotPresent: true (default)
      #   # Converts usages of `!present?` to `blank?`
      #
      #   # bad
      #   !foo.present?
      #
      #   # good
      #   foo.blank?
      #
      # @example UnlessPresent: true (default)
      #   # Converts usages of `unless present?` to `if blank?`
      #
      #   # bad
      #   something unless foo.present?
      #
      #   # good
      #   something if foo.blank?
      #
      #   # bad
      #   unless foo.present?
      #     something
      #   end
      #
      #   # good
      #   if foo.blank?
      #     something
      #   end
      #
      #   # good
      #   def blank?
      #     !present?
      #   end
      class Blank < Cop
        MSG_NIL_OR_EMPTY = 'Use `%<prefer>s` instead of `%<current>s`.'
        MSG_NOT_PRESENT = 'Use `%<prefer>s` instead of `%<current>s`.'
        MSG_UNLESS_PRESENT = 'Use `if %<prefer>s` instead of ' \
                             '`%<current>s`.'

        # `(send nil $_)` is not actually a valid match for an offense. Nodes
        # that have a single method call on the left hand side
        # (`bar || foo.empty?`) will blow up when checking
        # `(send (:nil) :== $_)`.
        def_node_matcher :nil_or_empty?, <<-PATTERN
          (or
              {
                (send $_ :!)
                (send $_ :nil?)
                (send $_ :== nil)
                (send nil :== $_)
              }
              {
                (send $_ :empty?)
                (send (send (send $_ :empty?) :!) :!)
              }
          )
        PATTERN

        def_node_matcher :not_present?, '(send (send $_ :present?) :!)'

        def_node_matcher :defining_blank?, '(def :blank? (args) ...)'

        def_node_matcher :unless_present?, <<-PATTERN
          (:if $(send $_ :present?) {nil? (...)} ...)
        PATTERN

        def on_send(node)
          return unless cop_config['NotPresent']

          not_present?(node) do |receiver|
            # accepts !present? if its in the body of a `blank?` method
            next if defining_blank?(node.parent)

            add_offense(node,
                        message: format(MSG_NOT_PRESENT,
                                        prefer: replacement(receiver),
                                        current: node.source))
          end
        end

        def on_or(node)
          return unless cop_config['NilOrEmpty']

          nil_or_empty?(node) do |var1, var2|
            return unless var1 == var2

            add_offense(node,
                        message: format(MSG_NIL_OR_EMPTY,
                                        prefer: replacement(var1),
                                        current: node.source))
          end
        end

        def on_if(node)
          return unless cop_config['UnlessPresent']
          return unless node.unless?
          return if node.else? && config.for_cop('Style/UnlessElse')['Enabled']

          unless_present?(node) do |method_call, receiver|
            range = unless_condition(node, method_call)

            add_offense(node,
                        location: range,
                        message: format(MSG_UNLESS_PRESENT,
                                        prefer: replacement(receiver),
                                        current: range.source))
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            method_call, variable1 = unless_present?(node)

            if method_call
              corrector.replace(node.loc.keyword, 'if')
              range = method_call.loc.expression
            else
              variable1, _variable2 = nil_or_empty?(node) || not_present?(node)
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
          node.respond_to?(:source) ? "#{node.source}.blank?" : 'blank?'
        end
      end
    end
  end
end
