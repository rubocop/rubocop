# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for usages of `Hash#reject`, `Hash#select`, and `Hash#filter` methods
      # that can be replaced with `Hash#except` method.
      #
      # This cop should only be enabled on Ruby version 3.0 or higher.
      # (`Hash#except` was added in Ruby 3.0.)
      #
      # For safe detection, it is limited to commonly used string and symbol comparisons
      # when used `==`.
      # And do not check `Hash#delete_if` and `Hash#keep_if` to change receiver object.
      #
      # @example
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k == :bar }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| k != :bar }
      #
      #   # good
      #   {foo: 1, bar: 2, baz: 3}.except(:bar)
      #
      class HashExcept < Base
        include RangeHelp
        extend TargetRubyVersion
        extend AutoCorrector

        minimum_target_ruby_version 3.0

        MSG = 'Use `%<prefer>s` instead.'
        RESTRICT_ON_SEND = %i[reject select filter].freeze

        # @!method bad_method?(node)
        def_node_matcher :bad_method?, <<~PATTERN
          (block
            (send _ _)
            (args
              (arg _)
              (arg _))
            (send
              _ {:== :!= :eql?} _))
        PATTERN

        def on_send(node)
          block = node.parent
          return unless bad_method?(block) && semantically_except_method?(node, block)

          except_key = except_key(block)
          return if except_key.nil? || !safe_to_register_offense?(block, except_key)

          range = offense_range(node)
          preferred_method = "except(#{except_key.source})"

          add_offense(range, message: format(MSG, prefer: preferred_method)) do |corrector|
            corrector.replace(range, preferred_method)
          end
        end

        private

        def semantically_except_method?(send, block)
          body = block.body

          case send.method_name
          when :reject
            body.method?('==') || body.method?('eql?')
          when :select, :filter
            body.method?('!=')
          else
            false
          end
        end

        def safe_to_register_offense?(block, except_key)
          return true if block.body.method?('eql?')

          except_key.sym_type? || except_key.str_type?
        end

        def except_key(node)
          key_argument = node.argument_list.first.source
          lhs, _method_name, rhs = *node.body
          return if [lhs, rhs].map(&:source).none?(key_argument)

          [lhs, rhs].find { |operand| operand.source != key_argument }
        end

        def offense_range(node)
          range_between(node.loc.selector.begin_pos, node.parent.loc.end.end_pos)
        end
      end
    end
  end
end
