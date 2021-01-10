# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of literal strings converted to
      # a symbol where a literal symbol could be used instead.
      #
      # @example
      #   # bad
      #   'string'.to_sym
      #   :symbol.to_sym
      #   'underscored_string'.to_sym
      #   :'underscored_symbol'
      #   'hyphenated-string'.to_sym
      #
      #   # good
      #   :string
      #   :symbol
      #   :underscored_string
      #   :underscored_symbol
      #   :'hyphenated-string'
      #
      class SymbolConversion < Base
        extend AutoCorrector

        MSG = 'Unnecessary symbol conversion; use `%<correction>s` instead.'
        RESTRICT_ON_SEND = %i[to_sym intern].freeze

        def on_send(node)
          return unless node.receiver.str_type? || node.receiver.sym_type?

          register_offense(node, correction: node.receiver.value.to_sym.inspect)
        end

        def on_sym(node)
          return if properly_quoted?(node.source, node.value.inspect)

          # `alias` arguments are symbols but since a symbol that requires
          # being quoted is not a valid method identifier, it can be ignored
          return if in_alias?(node)

          # The `%I[]` and `%i[]` macros are parsed as normal arrays of symbols
          # so they need to be ignored.
          return if in_percent_literal_array?(node)

          # Symbol hash keys have a different format and need to be handled separately
          return correct_hash_key(node) if hash_key?(node)

          register_offense(node, correction: node.value.inspect)
        end

        private

        def register_offense(node, correction:, message: format(MSG, correction: correction))
          add_offense(node, message: message) do |corrector|
            corrector.replace(node, correction)
          end
        end

        def properly_quoted?(source, value)
          return true unless source.match?(/['"]/)

          source == value ||
            # `Symbol#inspect` uses double quotes, but allow single-quoted
            # symbols to work as well.
            source.tr("'", '"') == value
        end

        def in_alias?(node)
          node.parent&.alias_type?
        end

        def in_percent_literal_array?(node)
          node.parent&.array_type? && node.parent&.percent_literal?
        end

        def hash_key?(node)
          node.parent&.pair_type? && node == node.parent.child_nodes.first
        end

        def correct_hash_key(node)
          # Although some operators can be converted to symbols normally
          # (ie. `:==`), these are not accepted as hash keys and will
          # raise a syntax error (eg. `{ ==: ... }`). Therefore, if the
          # symbol does not start with an alpha-numeric or underscore, it
          # will be ignored.
          return unless node.value.to_s.match?(/\A[a-z0-9_]/i)

          correction = node.value.inspect.delete(':')
          return if properly_quoted?(node.source, correction)

          register_offense(
            node,
            correction: correction,
            message: format(MSG, correction: "#{correction}:")
          )
        end
      end
    end
  end
end
