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
      # when used `==`.
      # And do not check `Hash#delete_if` and `Hash#keep_if` to change receiver object.
      #
      # @example
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k == :bar }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| %i[foo bar].include?(k) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| !%i[foo bar].include?(k) }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| !%i[foo bar].include?(k) }
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

        # @!method bad_method_with_poro?(node)
        def_node_matcher :bad_method_with_poro?, <<~PATTERN
          (block
            (send _ _)
            (args
              (arg _)
              (arg _))
            {
              (send
                _ {:== :!= :eql? :include?} _)
              (send
                (send
                  _ {:== :!= :eql? :include?} _) :!)
              })
        PATTERN

        # @!method bad_method_with_active_support?(node)
        def_node_matcher :bad_method_with_active_support?, <<~PATTERN
          (block
            (send _ _)
            (args
              (arg _)
              (arg _))
            {
              (send
                _ {:== :!= :eql? :in? :include? :exclude?} _)
              (send
                (send
                  _ {:== :!= :eql? :in? :include? :exclude?} _) :!)
              })
        PATTERN

        def on_send(node)
          block = node.parent
          return unless bad_method?(block) && semantically_except_method?(node, block)

          except_key = except_key(block)
          return if except_key.nil? || !safe_to_register_offense?(block, except_key)

          range = offense_range(node)
          preferred_method = "except(#{except_key_source(except_key)})"

          add_offense(range, message: format(MSG, prefer: preferred_method)) do |corrector|
            corrector.replace(range, preferred_method)
          end
        end

        private

        def bad_method?(block)
          if active_support_extensions_enabled?
            bad_method_with_active_support?(block)
          else
            bad_method_with_poro?(block)
          end
        end

        def semantically_except_method?(send, block)
          body = block.body

          negated = body.method?('!')
          body = body.receiver if negated

          case send.method_name
          when :reject
            body.method?('==') || body.method?('eql?') || included?(negated, body)
          when :select, :filter
            body.method?('!=') || not_included?(negated, body)
          else
            false
          end
        end

        def included?(negated, body)
          body.method?('include?') || body.method?('in?') || (negated && body.method?('exclude?'))
        end

        def not_included?(negated, body)
          body.method?('exclude?') || (negated && (body.method?('include?') || body.method?('in?')))
        end

        def safe_to_register_offense?(block, except_key)
          extracted = extract_body_if_nagated(block.body)
          if extracted.method?('in?') || extracted.method?('include?') || \
             extracted.method?('exclude?')
            return true
          end
          return true if block.body.method?('eql?')

          except_key.sym_type? || except_key.str_type?
        end

        def extract_body_if_nagated(body)
          return body unless body.method?('!')

          body.receiver
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
          key_argument = node.argument_list.first.source
          body = extract_body_if_nagated(node.body)
          lhs, _method_name, rhs = *body
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
