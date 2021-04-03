# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks the usage of pre-2.1 `Hash[args]` method of converting enumerables and
      # sequences of values to hashes.
      #
      # Correction code from splat argument (`Hash[*ary]`) is not simply determined. For example,
      # `Hash[*ary]` can be replaced with `ary.each_slice(2).to_h` but it will be complicated.
      # So, `AllowSplatArgument` option is true by default to allow splat argument for simple code.
      #
      # @example
      #   # bad
      #   Hash[ary]
      #
      #   # good
      #   ary.to_h
      #
      #   # bad
      #   Hash[key1, value1, key2, value2]
      #
      #   # good
      #   {key1 => value1, key2 => value2}
      #
      # @example AllowSplatArgument: true (default)
      #   # good
      #   Hash[*ary]
      #
      # @example AllowSplatArgument: false
      #   # bad
      #   Hash[*ary]
      #
      class HashConversion < Base
        extend AutoCorrector

        MSG_TO_H = 'Prefer ary.to_h to Hash[ary].'
        MSG_LITERAL_MULTI_ARG = 'Prefer literal hash to Hash[arg1, arg2, ...].'
        MSG_LITERAL_HASH_ARG = 'Prefer literal hash to Hash[key: value, ...].'
        MSG_SPLAT = 'Prefer array_of_pairs.to_h to Hash[*array].'
        RESTRICT_ON_SEND = %i[[]].freeze

        # @!method hash_from_array?(node)
        def_node_matcher :hash_from_array?, '(send (const {nil? cbase} :Hash) :[] ...)'

        def on_send(node)
          return unless hash_from_array?(node)

          # There are several cases:
          # If there is one argument:
          #   Hash[ary] => ary.to_h
          #   Hash[*ary] => don't suggest corrections
          # If there is 0 or 2+ arguments:
          #   Hash[a1, a2, a3, a4] => {a1 => a2, a3 => a4}
          #   ...but don't suggest correction if there is odd number of them (it is a bug)
          node.arguments.count == 1 ? single_argument(node) : multi_argument(node)
        end

        private

        def single_argument(node)
          first_argument = node.first_argument
          if first_argument.hash_type?
            add_offense(node, message: MSG_LITERAL_HASH_ARG) do |corrector|
              corrector.replace(node, "{#{first_argument.source}}")
            end
          elsif first_argument.splat_type?
            add_offense(node, message: MSG_SPLAT) unless allowed_splat_argument?
          else
            add_offense(node, message: MSG_TO_H) do |corrector|
              replacement = first_argument.source
              replacement = "(#{replacement})" if requires_parens?(first_argument)
              corrector.replace(node, "#{replacement}.to_h")
            end
          end
        end

        def requires_parens?(node)
          node.call_type? && node.arguments.any? && !node.parenthesized?
        end

        def multi_argument(node)
          if node.arguments.count.odd?
            add_offense(node, message: MSG_LITERAL_MULTI_ARG)
          else
            add_offense(node, message: MSG_LITERAL_MULTI_ARG) do |corrector|
              corrector.replace(node, args_to_hash(node.arguments))

              parent = node.parent
              add_parentheses(parent, corrector) if parent&.send_type? && !parent.parenthesized?
            end
          end
        end

        def args_to_hash(args)
          content = args.each_slice(2)
                        .map { |arg1, arg2| "#{arg1.source} => #{arg2.source}" }
                        .join(', ')
          "{#{content}}"
        end

        def allowed_splat_argument?
          cop_config.fetch('AllowSplatArgument', true)
        end
      end
    end
  end
end
