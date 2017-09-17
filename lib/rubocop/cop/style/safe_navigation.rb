# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop transforms usages of a method call safeguarded by a non `nil`
      # check for the variable whose method is being called to
      # safe navigation (`&.`).
      #
      # Configuration option: ConvertCodeThatCanStartToReturnNil
      # The default for this is `false`. When configured to `true`, this will
      # check for code in the format `!foo.nil? && foo.bar`. As it is written,
      # the return of this code is limited to `false` and whatever the return
      # of the method is. If this is converted to safe navigation,
      # `foo&.bar` can start returning `nil` as well as what the method
      # returns.
      #
      # @example
      #   # bad
      #   foo.bar if foo
      #   foo.bar(param1, param2) if foo
      #   foo.bar { |e| e.something } if foo
      #   foo.bar(param) { |e| e.something } if foo
      #
      #   foo.bar if !foo.nil?
      #   foo.bar unless !foo
      #   foo.bar unless foo.nil?
      #
      #   foo && foo.bar
      #   foo && foo.bar(param1, param2)
      #   foo && foo.bar { |e| e.something }
      #   foo && foo.bar(param) { |e| e.something }
      #
      #   # good
      #   foo&.bar
      #   foo&.bar(param1, param2)
      #   foo&.bar { |e| e.something }
      #   foo&.bar(param) { |e| e.something }
      #
      #   foo.nil? || foo.bar
      #   !foo || foo.bar
      #
      #   # Methods that `nil` will `respond_to?` should not be converted to
      #   # use safe navigation
      #   foo.to_i if foo
      class SafeNavigation < Cop
        extend TargetRubyVersion

        MSG = 'Use safe navigation (`&.`) instead of checking if an object ' \
              'exists before calling the method.'.freeze
        NIL_METHODS = nil.methods.freeze

        minimum_target_ruby_version 2.3

        # if format: (if checked_variable body nil)
        # unless format: (if checked_variable nil body)
        def_node_matcher :modifier_if_safe_navigation_candidate?, <<-PATTERN
          {
            (if {
                  (send $_ {:nil? :!})
                  $_
                } nil $_)

            (if {
                  (send (send $_ :nil?) :!)
                  $_
                } $_ nil)
          }
        PATTERN

        def_node_matcher :not_nil_check?, '(send (send $_ :nil?) :!)'

        def on_if(node)
          return if allowed_if_condition?(node)
          check_node(node)
        end

        def on_and(node)
          check_node(node)
        end

        def check_node(node)
          return if target_ruby_version < 2.3
          checked_variable, receiver, method = extract_parts(node)
          return unless receiver == checked_variable
          return if unsafe_method?(method)

          add_offense(node)
        end

        def autocorrect(node)
          _check, body, = node.node_parts
          _checked_variable, matching_receiver, = extract_parts(node)
          method_call, = matching_receiver.parent

          lambda do |corrector|
            corrector.remove(begin_range(node, body))
            corrector.remove(end_range(node, body))
            corrector.insert_before((method_call || body).loc.dot, '&')
          end
        end

        private

        def allowed_if_condition?(node)
          node.else? || node.elsif? || node.ternary?
        end

        def extract_parts(node)
          case node.type
          when :if
            extract_parts_from_if(node)
          when :and
            extract_parts_from_and(node)
          end
        end

        def extract_parts_from_if(node)
          checked_variable, receiver =
            modifier_if_safe_navigation_candidate?(node)

          extract_common_parts(receiver, checked_variable)
        end

        def extract_parts_from_and(node)
          checked_variable, rhs = *node
          if cop_config['ConvertCodeThatCanStartToReturnNil']
            checked_variable =
              not_nil_check?(checked_variable) || checked_variable
          end

          extract_common_parts(rhs, checked_variable)
        end

        def extract_common_parts(continuation, checked_variable)
          matching_receiver =
            find_matching_receiver_invocation(continuation, checked_variable)

          method = matching_receiver.parent if matching_receiver

          [checked_variable, matching_receiver, method]
        end

        def find_matching_receiver_invocation(node, checked_variable)
          return nil unless node

          receiver = if node.block_type?
                       node.send_node.receiver
                     else
                       node.receiver
                     end

          return receiver if receiver == checked_variable

          find_matching_receiver_invocation(receiver, checked_variable)
        end

        def unsafe_method?(send_node)
          NIL_METHODS.include?(send_node.method_name) ||
            negated?(send_node) || !send_node.dot?
        end

        def negated?(send_node)
          send_node.parent.send_type? && send_node.parent.method?(:!)
        end

        def begin_range(node, method_call)
          range_between(node.loc.expression.begin_pos,
                        method_call.loc.expression.begin_pos)
        end

        def end_range(node, method_call)
          range_between(method_call.loc.expression.end_pos,
                        node.loc.expression.end_pos)
        end
      end
    end
  end
end
