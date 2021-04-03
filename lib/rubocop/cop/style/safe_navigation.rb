# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop transforms usages of a method call safeguarded by a non `nil`
      # check for the variable whose method is being called to
      # safe navigation (`&.`). If there is a method chain, all of the methods
      # in the chain need to be checked for safety, and all of the methods will
      # need to be changed to use safe navigation. We have limited the cop to
      # not register an offense for method chains that exceed 2 methods.
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
      #   foo.bar.baz if foo
      #   foo.bar(param1, param2) if foo
      #   foo.bar { |e| e.something } if foo
      #   foo.bar(param) { |e| e.something } if foo
      #
      #   foo.bar if !foo.nil?
      #   foo.bar unless !foo
      #   foo.bar unless foo.nil?
      #
      #   foo && foo.bar
      #   foo && foo.bar.baz
      #   foo && foo.bar(param1, param2)
      #   foo && foo.bar { |e| e.something }
      #   foo && foo.bar(param) { |e| e.something }
      #
      #   # good
      #   foo&.bar
      #   foo&.bar&.baz
      #   foo&.bar(param1, param2)
      #   foo&.bar { |e| e.something }
      #   foo&.bar(param) { |e| e.something }
      #   foo && foo.bar.baz.qux # method chain with more than 2 methods
      #   foo && foo.nil? # method that `nil` responds to
      #
      #   # Method calls that do not use `.`
      #   foo && foo < bar
      #   foo < bar if foo
      #
      #   # When checking `foo&.empty?` in a conditional, `foo` being `nil` will actually
      #   # do the opposite of what the author intends.
      #   foo && foo.empty?
      #
      #   # This could start returning `nil` as well as the return of the method
      #   foo.nil? || foo.bar
      #   !foo || foo.bar
      #
      #   # Methods that are used on assignment, arithmetic operation or
      #   # comparison should not be converted to use safe navigation
      #   foo.baz = bar if foo
      #   foo.baz + bar if foo
      #   foo.bar > 2 if foo
      class SafeNavigation < Base
        include NilMethods
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use safe navigation (`&.`) instead of checking if an object ' \
              'exists before calling the method.'
        LOGIC_JUMP_KEYWORDS = %i[break fail next raise return throw yield].freeze

        # if format: (if checked_variable body nil)
        # unless format: (if checked_variable nil body)
        # @!method modifier_if_safe_navigation_candidate(node)
        def_node_matcher :modifier_if_safe_navigation_candidate, <<~PATTERN
          {
            (if {
                  (send $_ {:nil? :!})
                  $_
                } nil? $_)

            (if {
                  (send (send $_ :nil?) :!)
                  $_
                } $_ nil?)
          }
        PATTERN

        # @!method not_nil_check?(node)
        def_node_matcher :not_nil_check?, '(send (send $_ :nil?) :!)'

        def on_if(node)
          return if allowed_if_condition?(node)

          check_node(node)
        end

        def on_and(node)
          check_node(node)
        end

        def check_node(node)
          checked_variable, receiver, method_chain, method = extract_parts(node)
          return unless receiver == checked_variable
          return if use_var_only_in_unless_modifier?(node, checked_variable)
          # method is already a method call so this is actually checking for a
          # chain greater than 2
          return if chain_size(method_chain, method) > 1
          return if unsafe_method_used?(method_chain, method)
          return if method_chain.method?(:empty?)

          add_offense(node) { |corrector| autocorrect(corrector, node) }
        end

        def use_var_only_in_unless_modifier?(node, variable)
          node.if_type? && node.unless? && !method_called?(variable)
        end

        private

        def autocorrect(corrector, node)
          body = node.node_parts[1]
          method_call = method_call(node)

          corrector.remove(begin_range(node, body))
          corrector.remove(end_range(node, body))
          corrector.insert_before(method_call.loc.dot, '&')
          handle_comments(corrector, node, method_call)

          add_safe_nav_to_all_methods_in_chain(corrector, method_call, body)
        end

        def handle_comments(corrector, node, method_call)
          comments = comments(node)
          return if comments.empty?

          corrector.insert_before(method_call, "#{comments.map(&:text).join("\n")}\n")
        end

        def comments(node)
          relevant_comment_ranges(node).each.with_object([]) do |range, comments|
            comments.concat(processed_source.each_comment_in_lines(range).to_a)
          end
        end

        def relevant_comment_ranges(node)
          # Get source lines ranges inside the if node that aren't inside an inner node
          # Comments inside an inner node should remain attached to that node, and not
          # moved.
          begin_pos = node.loc.first_line
          end_pos = node.loc.last_line

          node.child_nodes.each.with_object([]) do |child, ranges|
            ranges << (begin_pos...child.loc.first_line)
            begin_pos = child.loc.last_line
          end << (begin_pos...end_pos)
        end

        def allowed_if_condition?(node)
          node.else? || node.elsif? || node.ternary?
        end

        def method_call(node)
          _checked_variable, matching_receiver, = extract_parts(node)
          matching_receiver.parent
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
          variable, receiver = modifier_if_safe_navigation_candidate(node)

          checked_variable, matching_receiver, method = extract_common_parts(receiver, variable)

          matching_receiver = nil if receiver && LOGIC_JUMP_KEYWORDS.include?(receiver.type)

          [checked_variable, matching_receiver, receiver, method]
        end

        def extract_parts_from_and(node)
          checked_variable, rhs = *node
          if cop_config['ConvertCodeThatCanStartToReturnNil']
            checked_variable = not_nil_check?(checked_variable) || checked_variable
          end

          checked_variable, matching_receiver, method = extract_common_parts(rhs, checked_variable)
          [checked_variable, matching_receiver, rhs, method]
        end

        def extract_common_parts(method_chain, checked_variable)
          matching_receiver = find_matching_receiver_invocation(method_chain, checked_variable)

          method = matching_receiver.parent if matching_receiver

          [checked_variable, matching_receiver, method]
        end

        def find_matching_receiver_invocation(method_chain, checked_variable)
          return nil unless method_chain

          receiver = if method_chain.block_type?
                       method_chain.send_node.receiver
                     else
                       method_chain.receiver
                     end

          return receiver if receiver == checked_variable

          find_matching_receiver_invocation(receiver, checked_variable)
        end

        def chain_size(method_chain, method)
          method.each_ancestor(:send).inject(0) do |total, ancestor|
            break total + 1 if ancestor == method_chain

            total + 1
          end
        end

        def unsafe_method_used?(method_chain, method)
          return true if unsafe_method?(method)

          method.each_ancestor(:send).any? do |ancestor|
            break true unless config.for_cop('Lint/SafeNavigationChain')['Enabled']

            break true if unsafe_method?(ancestor)
            break true if nil_methods.include?(ancestor.method_name)
            break false if ancestor == method_chain
          end
        end

        def unsafe_method?(send_node)
          negated?(send_node) || send_node.assignment? || !send_node.dot?
        end

        def negated?(send_node)
          if method_called?(send_node)
            negated?(send_node.parent)
          else
            send_node.send_type? && send_node.method?(:!)
          end
        end

        def method_called?(send_node)
          send_node&.parent&.send_type?
        end

        def begin_range(node, method_call)
          range_between(node.loc.expression.begin_pos, method_call.loc.expression.begin_pos)
        end

        def end_range(node, method_call)
          range_between(method_call.loc.expression.end_pos, node.loc.expression.end_pos)
        end

        def add_safe_nav_to_all_methods_in_chain(corrector,
                                                 start_method,
                                                 method_chain)
          start_method.each_ancestor do |ancestor|
            break unless %i[send block].include?(ancestor.type)
            next unless ancestor.send_type?

            corrector.insert_before(ancestor.loc.dot, '&')

            break if ancestor == method_chain
          end
        end
      end
    end
  end
end
