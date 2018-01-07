# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `Hash#merge!` can be replaced by
      # `Hash#[]=`.
      #
      # @example
      #   hash.merge!(a: 1)
      #   hash.merge!({'key' => 'value'})
      #   hash.merge!(a: 1, b: 2)
      class RedundantMerge < Cop
        AREF_ASGN = '%<receiver>s[%<key>s] = %<value>s'.freeze
        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'.freeze

        def_node_matcher :redundant_merge_candidate, <<-PATTERN
          (send $!nil? :merge! [(hash $...) !kwsplat_type?])
        PATTERN

        def_node_matcher :modifier_flow_control?, <<-PATTERN
          [{if while until} modifier_form?]
        PATTERN

        def on_send(node)
          each_redundant_merge(node) do |redundant_merge_node|
            add_offense(redundant_merge_node)
          end
        end

        def autocorrect(node)
          redundant_merge_candidate(node) do |receiver, pairs|
            new_source = to_assignments(receiver, pairs).join("\n")

            if node.parent && pairs.size > 1
              correct_multiple_elements(node, node.parent, new_source)
            else
              correct_single_element(node, new_source)
            end
          end
        end

        private

        def message(node)
          redundant_merge_candidate(node) do |receiver, pairs|
            assignments = to_assignments(receiver, pairs).join('; ')

            format(MSG, prefer: assignments, current: node.source)
          end
        end

        def each_redundant_merge(node)
          redundant_merge_candidate(node) do |receiver, pairs|
            next if non_redundant_merge?(node, receiver, pairs)

            yield node
          end
        end

        def non_redundant_merge?(node, receiver, pairs)
          non_redundant_pairs?(receiver, pairs) ||
            non_redundant_value_used?(receiver, node)
        end

        def non_redundant_pairs?(receiver, pairs)
          pairs.size > 1 && !receiver.pure? || pairs.size > max_key_value_pairs
        end

        def non_redundant_value_used?(receiver, node)
          node.value_used? &&
            !EachWithObjectInspector.new(node, receiver).value_used?
        end

        def correct_multiple_elements(node, parent, new_source)
          if modifier_flow_control?(parent)
            new_source = rewrite_with_modifier(node, parent, new_source)
            node = parent
          else
            padding = "\n#{leading_spaces(node)}"
            new_source.gsub!(/\n/, padding)
          end

          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end

        def correct_single_element(node, new_source)
          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end

        def to_assignments(receiver, pairs)
          pairs.map do |pair|
            key, value = *pair

            key = key.sym_type? && pair.colon? ? ":#{key.source}" : key.source

            format(AREF_ASGN, receiver: receiver.source,
                              key: key,
                              value: value.source)
          end
        end

        def rewrite_with_modifier(node, parent, new_source)
          cond, = *parent
          padding = "\n#{(' ' * indent_width) + leading_spaces(node)}"
          new_source.gsub!(/\n/, padding)

          parent.loc.keyword.source << ' ' << cond.source << padding <<
            new_source << "\n" << leading_spaces(node) << 'end'
        end

        def leading_spaces(node)
          node.source_range.source_line[/\A\s*/]
        end

        def indent_width
          @config.for_cop('IndentationWidth')['Width'] || 2
        end

        def max_key_value_pairs
          Integer(cop_config['MaxKeyValuePairs'])
        end

        # A utility class for checking the use of values within an
        # `each_with_object` call.
        class EachWithObjectInspector
          extend NodePattern::Macros

          def initialize(node, receiver)
            @node = node
            @receiver = unwind(receiver)
          end

          def value_used?
            return false unless eligible_receiver? && second_argument

            receiver.loc.name.source == second_argument.loc.name.source
          end

          private

          attr_reader :node, :receiver

          def eligible_receiver?
            receiver.respond_to?(:lvar_type?) && receiver.lvar_type?
          end

          def second_argument
            parent = node.parent
            parent = parent.parent if parent.begin_type?

            @second_argument ||= each_with_object_node(parent)
          end

          def unwind(receiver)
            while receiver.respond_to?(:send_type?) && receiver.send_type?
              receiver, = *receiver
            end
            receiver
          end

          def_node_matcher :each_with_object_node, <<-PATTERN
            (block (send _ :each_with_object _) (args _ $_) ...)
          PATTERN
        end
      end
    end
  end
end
