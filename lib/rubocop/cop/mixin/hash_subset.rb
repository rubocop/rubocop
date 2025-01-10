# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Style/HashExcept and Style/HashSlice cops.
    # It registers an offense on methods with blocks that are equivalent
    # to Hash#except or Hash#slice.
    module HashSubset
      include RangeHelp
      extend NodePattern::Macros

      RESTRICT_ON_SEND = %i[reject select filter].freeze

      SUBSET_METHODS = %i[== != eql? include?].freeze
      ACTIVE_SUPPORT_SUBSET_METHODS = (SUBSET_METHODS + %i[in? exclude?]).freeze

      MSG = 'Use `%<prefer>s` instead.'

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
        offense_range, key_source = extract_offense(node)

        return unless offense_range
        return unless semantically_subset_method?(node)

        preferred_method = "#{preferred_method_name}(#{key_source})"
        add_offense(offense_range, message: format(MSG, prefer: preferred_method)) do |corrector|
          corrector.replace(offense_range, preferred_method)
        end
      end
      alias on_csend on_send

      private

      def semantically_subset_method?(node)
        raise NotImplementedError
      end

      def preferred_method_name
        raise NotImplementedError
      end

      def extract_offense(node)
        block = node.parent
        return unless extracts_hash_subset?(block)

        except_key = except_key(block)
        return if except_key.nil? || !safe_to_register_offense?(block, except_key)

        [offense_range(node), except_key_source(except_key)]
      end

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

      def semantically_except_method?(node)
        block = node.parent
        body, negated = extract_body_if_negated(block.body)

        if node.method?('reject')
          body.method?('==') || body.method?('eql?') || included?(body, negated)
        else
          body.method?('!=') || not_included?(body, negated)
        end
      end

      def semantically_slice_method?(node)
        !semantically_except_method?(node)
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
