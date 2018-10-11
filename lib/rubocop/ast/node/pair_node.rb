# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `pair` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `pair` nodes within RuboCop.
    class PairNode < Node
      include HashElementNode

      HASH_ROCKET = '=>'.freeze
      SPACED_HASH_ROCKET = ' => '.freeze
      COLON = ':'.freeze
      SPACED_COLON = ': '.freeze

      # Checks whether the `pair` uses a hash rocket delimiter.
      #
      # @return [Boolean] whether this `pair` uses a hash rocket delimiter
      def hash_rocket?
        loc.operator.is?(HASH_ROCKET)
      end

      # Checks whether the `pair` uses a colon delimiter.
      #
      # @return [Boolean] whether this `pair` uses a colon delimiter
      def colon?
        loc.operator.is?(COLON)
      end

      # Returns the delimiter of the `pair` as a string. Returns `=>` for a
      # colon delimited `pair` and `:` for a hash rocket delimited `pair`.
      #
      # @param [Boolean] with_spacing whether to include spacing
      # @return [String] the delimiter of the `pair`
      def delimiter(with_spacing = false)
        if with_spacing
          hash_rocket? ? SPACED_HASH_ROCKET : SPACED_COLON
        else
          hash_rocket? ? HASH_ROCKET : COLON
        end
      end

      # Returns the inverse delimiter of the `pair` as a string.
      #
      # @param [Boolean] with_spacing whether to include spacing
      # @return [String] the inverse delimiter of the `pair`
      def inverse_delimiter(with_spacing = false)
        if with_spacing
          hash_rocket? ? SPACED_COLON : SPACED_HASH_ROCKET
        else
          hash_rocket? ? COLON : HASH_ROCKET
        end
      end

      # Checks whether the value starts on its own line.
      #
      # @return [Boolean] whether the value in the `pair` starts its own line
      def value_on_new_line?
        key.loc.line != value.loc.line
      end
    end
  end
end
