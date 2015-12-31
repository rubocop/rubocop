# encoding: utf-8

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
        AREF_ASGN = '%s[%s] = %s'
        MSG = 'Use `%s` instead of `%s`.'

        def_node_matcher :redundant_merge, <<-END
          (send $_ :merge! (hash $...))
        END

        def on_send(node)
          redundant_merge(node) do |receiver, pairs|
            next if node.value_used?
            next if pairs.size > 1 && !receiver.pure?

            assignments = to_assignments(receiver, pairs).join('; ')
            message = format(MSG, assignments, node.source)
            add_offense(node, :expression, message)
          end
        end

        def autocorrect(node)
          redundant_merge(node) do |receiver, pairs|
            lambda do |corrector|
              new_source = to_assignments(receiver, pairs).join("\n")
              corrector.replace(node.source_range, new_source)
            end
          end
        end

        private

        def to_assignments(receiver, pairs)
          pairs.map do |pair|
            key, value = *pair
            key_src = if key.sym_type? && !key.source.start_with?(':')
                        ':' << key.source
                      else
                        key.source
                      end

            format(AREF_ASGN, receiver.source, key_src, value.source)
          end
        end
      end
    end
  end
end
