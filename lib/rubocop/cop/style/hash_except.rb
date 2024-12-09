# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for usages of `Hash#reject`, `Hash#select`, and `Hash#filter` methods
      # that can be replaced with `Hash#except` method.
      #
      # This cop should only be enabled on Ruby version 3.0 or higher.
      # (`Hash#except` was added in Ruby 3.0.)
      #
      # For safe detection, it is limited to commonly used string and symbol comparisons
      # when using `==` or `!=`.
      #
      # This cop doesn't check for `Hash#delete_if` and `Hash#keep_if` because they
      # modify the receiver.
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the receiver
      #   is a `Hash` or responds to the replacement method.
      #
      # @example
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k == :bar }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k.eql?(:bar) }
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| %i[bar].include?(k) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| !%i[bar].include?(k) }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| !%i[bar].include?(k) }
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| !%i[bar].exclude?(k) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| %i[bar].exclude?(k) }
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k.in?(%i[bar]) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| !k.in?(%i[bar]) }
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

        SUBSET_METHODS = %i[== != eql? include?].freeze
        ACTIVE_SUPPORT_SUBSET_METHODS = (SUBSET_METHODS + %i[in? exclude?]).freeze

        # @!method block_with_first_arg_check?(node)
        def_node_matcher :block_with_first_arg_check?, <<~PATTERN
          (block
            (call _ _)
            (args
              $(arg _key)
              (arg _))
            {
              $(send
                {(lvar _key) $_ _ | _ $_ (lvar _key)})
              (send
                $(send
                  {(lvar _key) $_ _ | _ $_ (lvar _key)}) :!)
              })
        PATTERN

        def on_send(node)
          block = node.parent
          return unless extracts_hash_subset?(block) && semantically_except_method?(node, block)

          except_key = except_key(block)
          return unless safe_to_register_offense?(block, except_key)

          range = offense_range(node)
          preferred_method = "except(#{except_key_source(except_key)})"

          add_offense(range, message: format(MSG, prefer: preferred_method)) do |corrector|
            corrector.replace(range, preferred_method)
          end
        end
        alias on_csend on_send

        private

        def extracts_hash_subset?(block)
          block_with_first_arg_check?(block) do |key_arg, send_node, method|
            return false unless supported_subset_method?(method)

            case method
            when :include?, :exclude?
              send_node.first_argument.source == key_arg.source
            when :in?
              send_node.receiver.source == key_arg.source
            else
              true
            end
          end
        end

        def supported_subset_method?(method)
          if active_support_extensions_enabled?
            ACTIVE_SUPPORT_SUBSET_METHODS.include?(method)
          else
            SUBSET_METHODS.include?(method)
          end
        end

        def semantically_except_method?(node, block)
          body, negated = extract_body_if_negated(block.body)

          if node.method?('reject')
            body.method?('==') || body.method?('eql?') || included?(body, negated)
          else
            body.method?('!=') || not_included?(body, negated)
          end
        end

        def included?(body, negated)
          if negated
            body.method?('exclude?')
          else
            body.method?('include?') || body.method?('in?')
          end
        end

        def not_included?(body, negated)
          included?(body, !negated)
        end

        def safe_to_register_offense?(block, except_key)
          body = block.body

          if body.method?('==') || body.method?('!=')
            except_key.sym_type? || except_key.str_type?
          else
            true
          end
        end

        def extract_body_if_negated(body)
          if body.method?('!')
            [body.receiver, true]
          else
            [body, false]
          end
        end

        def except_key_source(key)
          if key.array_type?
            key = if key.percent_literal?
                    key.each_value.map { |v| decorate_source(v) }
                  else
                    key.each_value.map(&:source)
                  end
            return key.join(', ')
          end

          key.literal? ? key.source : "*#{key.source}"
        end

        def decorate_source(value)
          return ":\"#{value.source}\"" if value.dsym_type?
          return "\"#{value.source}\"" if value.dstr_type?
          return ":#{value.source}" if value.sym_type?

          "'#{value.source}'"
        end

        def except_key(node)
          key_arg = node.argument_list.first.source
          body, = extract_body_if_negated(node.body)
          lhs, _method_name, rhs = *body

          lhs.source == key_arg ? rhs : lhs
        end

        def offense_range(node)
          range_between(node.loc.selector.begin_pos, node.parent.loc.end.end_pos)
        end
      end
    end
  end
end
