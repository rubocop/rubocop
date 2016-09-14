# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop transforms usages of a method call safeguarded by a non `nil`
      # check for the variable whose method is being called to
      # safe navigation (`&.`).
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
      #   foo.nil? || foo.bar
      #   !foo || foo.bar
      #
      #   # good
      #   foo&.bar
      #   foo&.bar(param1, param2)
      #   foo&.bar { |e| e.something }
      #   foo&.bar(param) { |e| e.something }
      #
      #   # Methods that `nil` will `respond_to?` should not be converted to
      #   # use safe navigation
      #   foo.to_i if foo
      class SafeNavigation < Cop
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
            (and
              {(send (send $_ :nil?) :!) $_}
              {(send $_ $_ ...) (block (send $_ $_ ...) ...)}
            ...)
            (or
              (send $_ {:nil? :!})
              {(send $_ $_ ...) (block (send $_ $_ ...) ...)}
            ...)
          }
        PATTERN

        def on_if(node)
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
          checked_variable, receiver, method = safe_navigation_candidate(node)
          return unless receiver == checked_variable
          return if NIL_METHODS.include?(method)
          return unless method =~ /\w+[=!?]?/
          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            if node.loc.respond_to?(:keyword) && node.loc.keyword.is?('unless')
              _variable_check, _else, method_call = *node
            else
              _variable_check, method_call = *node
            end

            if method_call.block_type?
              method, = *method_call
              corrector.insert_before(method.loc.dot, '&')
            else
              corrector.insert_before(method_call.loc.dot, '&')
            end

            corrector.remove(range(node, method_call))
          end
        end

        private

        def range(node, method_call)
          source_buffer = node.loc.expression.source_buffer
          node_expression = node.loc.expression
          method_expression = method_call.loc.expression

          if node.and_type? || node.or_type?
            Parser::Source::Range.new(source_buffer,
                                      node_expression.begin_pos,
                                      method_expression.begin_pos)
          else
            Parser::Source::Range.new(source_buffer,
                                      method_expression.end_pos,
                                      node_expression.end_pos)
          end
        end
      end
    end
  end
end
