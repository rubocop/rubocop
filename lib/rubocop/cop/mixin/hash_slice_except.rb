# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Style/HashExcept and Style/HashSlice
    module HashSliceExcept
      include RangeHelp
      extend NodePattern::Macros

      RESTRICT_ON_SEND = %i[reject select filter].freeze

      # @!method bad_method_with_poro?(node)
      def_node_matcher :bad_method_with_poro?, <<~PATTERN
        (block
          (call _ _)
          (args
            $(arg _)
            (arg _))
          {
            $(send
              _ {:== :!= :eql? :include?} _)
            (send
              $(send
                _ {:== :!= :eql? :include?} _) :!)
            })
      PATTERN

      # @!method bad_method_with_active_support?(node)
      def_node_matcher :bad_method_with_active_support?, <<~PATTERN
        (block
          (send _ _)
          (args
            $(arg _)
            (arg _))
          {
            $(send
              _ {:== :!= :eql? :in? :include? :exclude?} _)
            (send
              $(send
                _ {:== :!= :eql? :in? :include? :exclude?} _) :!)
            })
      PATTERN

      def on_send(node)
        raise NotImplementedError
      end

      private

      def extract_offense(node)
        block = node.parent
        return unless bad_method?(block)

        except_key = except_key(block)
        return if except_key.nil? || !safe_to_register_offense?(block, except_key)

        [offense_range(node), except_key_source(except_key)]
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def bad_method?(block)
        if active_support_extensions_enabled?
          bad_method_with_active_support?(block) do |key_arg, send_node|
            return false if send_node.method?(:in?) && send_node.receiver&.source != key_arg.source
            return true if !send_node.method?(:include?) && !send_node.method?(:exclude?)

            send_node.first_argument&.source == key_arg.source
          end
        else
          bad_method_with_poro?(block) do |key_arg, send_node|
            !send_node.method?(:include?) || send_node.first_argument&.source == key_arg.source
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def semantically_except_method?(send)
        block = send.parent
        body = block.body

        negated = body.method?('!')
        body = body.receiver if negated

        case send.method_name
        when :reject
          body.method?('==') || body.method?('eql?') || included?(negated, body)
        when :select, :filter
          body.method?('!=') || not_included?(negated, body)
        end
      end

      def semantically_slice_method?(send)
        semantically_except_method?(send) == false
      end

      def included?(negated, body)
        if negated
          body.method?('exclude?')
        else
          body.method?('include?') || body.method?('in?')
        end
      end

      def not_included?(negated, body)
        included?(!negated, body)
      end

      def safe_to_register_offense?(block, except_key)
        extracted = extract_body_if_negated(block.body)
        if extracted.method?('in?') || extracted.method?('include?') ||
           extracted.method?('exclude?')
          return true
        end
        return true if block.body.method?('eql?')

        except_key.sym_type? || except_key.str_type?
      end

      def extract_body_if_negated(body)
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
        body = extract_body_if_negated(node.body)
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
