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
        include IfNode

        MSG = 'Use safe navigation (`&.`) instead of checking if an object ' \
              'exists before calling the method.'.freeze
        NIL_METHODS = nil.methods.freeze

        def_node_matcher :safe_navigation_candidate, <<-PATTERN
          {
            (if
              {(send (send $_ :nil?) :!) $_}
              {(send $_ $_ ...) (block (send $_ $_ ...) ...)}
            ...)
            (if
              (send $_ {:nil? :!}) nil
              {(send $_ $_ ...) (block (send $_ $_ ...) ...)}
            ...)
          }
        PATTERN

        def_node_matcher :candidate_that_may_introduce_nil, <<-PATTERN
          (and
            {(send (send $_ :nil?) :!) $_}
            {(send $_ $_ ...) (block (send $_ $_ ...) ...)}
          ...)
        PATTERN

        def on_if(node)
          return if ternary?(node)
          check_node(node)
        end

        def on_and(node)
          check_node(node)
        end

        def on_or(node)
          check_node(node)
        end

        def check_node(node)
          return if target_ruby_version < 2.3
          return if if_else?(node)
          return if elsif?(node)
          checked_variable, receiver, method = extract_parts(node)
          return unless receiver == checked_variable
          return if NIL_METHODS.include?(method)
          return unless method =~ /\w+[=!?]?/
          add_offense(node, :expression)
        end

        def extract_parts(node)
          if cop_config['ConvertCodeThatCanStartToReturnNil']
            safe_navigation_candidate(node) ||
              candidate_that_may_introduce_nil(node)
          else
            safe_navigation_candidate(node)
          end
        end

        def autocorrect(node)
          if node.loc.respond_to?(:keyword) && node.loc.keyword.is?('unless')
            _check, _else, body = *node
          else
            _check, body = *node
          end

          method_call, = *body if body.block_type?

          lambda do |corrector|
            corrector.remove(begin_range(node, body))
            corrector.remove(end_range(node, body))
            corrector.insert_before((method_call || body).loc.dot, '&')
          end
        end

        private

        def begin_range(node, method_call)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.loc.expression.begin_pos,
                                    method_call.loc.expression.begin_pos)
        end

        def end_range(node, method_call)
          Parser::Source::Range.new(node.loc.expression,
                                    method_call.loc.expression.end_pos,
                                    node.loc.expression.end_pos)
        end
      end
    end
  end
end
