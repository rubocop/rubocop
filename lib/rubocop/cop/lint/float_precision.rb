# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Identifies Float literals that lose precision when parsed.
      #
      # Ruby's Float class has limited precision, so some literal values
      # cannot be represented exactly and will be rounded. This cop identifies
      # those cases where the original literal does not match the parsed value.
      #
      # @example
      #
      #   # bad
      #   100000000000.000000000001 # becomes 100000000000.0
      #   10000000000000001.0       # becomes 1.0e+16
      #   1234567890123456789e0     # becomes 1.2345678901234568e+18
      #
      #   # good
      #   0.0
      #   1.0
      #   1.1
      #   10000.0
      #   1_000.0
      class FloatPrecision < Base
        MSG = 'Float literal is not precisely representable and becomes `%<interpreted>s`.'

        def on_float(node)
          on_precision_not_preserved(node) do |interpreted|
            add_offense(node, message: format(MSG, interpreted: interpreted))
          end
        end

        private

        def on_precision_not_preserved(node)
          if node.value.infinite? || node.value.nan?
            yield node.value.to_s
          else
            original = normalize_float_str(node.source.delete('_+'))
            interpreted = normalize_float_str(node.value.to_s)

            yield interpreted if original != interpreted
          end
        end

        def normalize_float_str(float)
          float = normalize_scientific_notation_float_str(float) if float.downcase.include?('e')

          float.gsub(/(?<!\.)0+$/, '')
        end

        def normalize_scientific_notation_float_str(float)
          significand, exponent = split_scientific_notation_float(float)

          return significand if significand == '0.0'

          decimal_pos = significand.index('.')
          decimal_pos ||= significand.length - 1

          insert_decimal(significand, decimal_pos + exponent.to_i)
        end

        def split_scientific_notation_float(float)
          parts = float.downcase.split('e')

          # Append a decimal point to the significand if it doesn't have one
          parts[0] = "#{parts[0]}.0" unless parts[0].include?('.')

          parts
        end

        def insert_decimal(float, pos)
          negative = float[0] == '-'
          if negative
            float = float.delete('-')
            pos -= 1
          end

          float = insert_decimal_positive(float, pos)

          float = "-#{float}" if negative
          float
        end

        def insert_decimal_positive(float, pos)
          float = float.delete('.')
          if pos >= float.length
            # Pad with zeros to the right
            float = float.ljust(pos + 3, '0')
          elsif pos <= 0
            # Pad with zeros to the left
            float = float.rjust(float.length + -pos + 1, '0')
            pos = 1
          end

          float.insert(pos, '.')
          float.gsub(/\A0(\d)/, '\1') # Delete insignificant leading zero
        end
      end
    end
  end
end
