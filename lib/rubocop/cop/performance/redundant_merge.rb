# encoding: utf-8
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
        AREF_ASGN = '%s[%s] = %s'.freeze
        MSG = 'Use `%s` instead of `%s`.'.freeze

        def_node_matcher :redundant_merge,
                         '(send $_ {:merge! :update} (hash $...))'
        def_node_matcher :modifier_flow_control, '[{if while until} #modifier?]'

        def on_send(node)
          redundant_merge(node) do |receiver, pairs|
            next if node.value_used?
            next if pairs.size > 1 && !receiver.pure?
            next if pairs.size > max_key_value_pairs

            assignments = to_assignments(receiver, pairs).join('; ')
            message = format(MSG, assignments, node.source)
            add_offense(node, :expression, message)
          end
        end

        def autocorrect(node)
          redundant_merge(node) do |receiver, pairs|
            lambda do |corrector|
              new_source = to_assignments(receiver, pairs).join("\n")

              parent = node.parent
              if parent && pairs.size > 1
                if modifier_flow_control(parent)
                  cond, = *parent
                  padding = "\n#{' ' * indent_width}"
                  new_source.gsub!(/\n/, padding)
                  new_source = parent.loc.keyword.source << ' ' <<
                               cond.source << padding << leading_spaces(node) <<
                               new_source << "\n" << leading_spaces(node) <<
                               'end'
                  node = parent
                end
              end

              corrector.replace(node.source_range, new_source)
            end
          end
        end

        private

        def to_assignments(receiver, pairs)
          pairs.map do |pair|
            key, value = *pair
            key_src = if key.sym_type? && !key.source.start_with?(':')
                        ":#{key.source}"
                      else
                        key.source
                      end

            format(AREF_ASGN, receiver.source, key_src, value.source)
          end
        end

        def leading_spaces(node)
          node.source_range.source_line[/\A\s*/]
        end

        def indent_width
          @config.for_cop('IndentationWidth')['Width'] || 2
        end

        def modifier?(node)
          node.loc.respond_to?(:end) && node.loc.end.nil?
        end

        def max_key_value_pairs
          cop_config['MaxKeyValuePairs'].to_i
        end
      end
    end
  end
end
