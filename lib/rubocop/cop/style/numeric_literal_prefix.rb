# encoding: utf-8
# frozen_string_literal: true

require 'pry'

module RuboCop
  module Cop
    module Style
      # This cop checks for octal, hex, binary and decimal literals using
      # uppercase prefixes and corrects them to lowercase prefix
      # or no prefix (in case of decimals).
      # eg. for octal use `0o` instead of `0` or `0O`.
      #
      # Can be configured to use `0` only for octal literals using
      # `EnforcedOctalStyle` => `zero_only`
      class NumericLiteralPrefix < Cop
        include IntegerNode

        OCTAL_ZERO_ONLY_REGEX = /^0[Oo][0-7]+$/
        OCTAL_REGEX = /^0O?[0-7]+$/
        HEX_REGEX = /^0X[0-9A-F]+$/
        BINARY_REGEX = /^0B[01]+$/
        DECIMAL_REGEX = /^0[dD][0-9]+$/

        OCTAL_ZERO_ONLY_MSG = 'Use 0 for octal literals.'.freeze
        OCTAL_MSG = 'Use 0o for octal literals.'.freeze
        HEX_MSG = 'Use 0x for hexadecimal literals.'.freeze
        BINARY_MSG = 'Use 0b for binary literals.'.freeze
        DECIMAL_MSG = 'Do not use prefixes for decimal literals.'.freeze

        def on_int(node)
          type = literal_type(node)
          return unless type

          msg = self.class.const_get("#{type.upcase}_MSG")
          add_offense(node, :expression, msg)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            type = literal_type(node)
            corrector.replace(node.source_range,
                              send(:"format_#{type}", node.source))
          end
        end

        def literal_type(node)
          literal = integer_part(node)

          if literal =~ OCTAL_ZERO_ONLY_REGEX && octal_zero_only?
            return :octal_zero_only
          elsif literal =~ OCTAL_REGEX && !octal_zero_only?
            return :octal
          end

          case literal
          when HEX_REGEX
            :hex
          when BINARY_REGEX
            :binary
          when DECIMAL_REGEX
            :decimal
          end
        end

        def octal_zero_only?
          cop_config['EnforcedOctalStyle'] == 'zero_only'
        end

        def format_octal(source)
          source.sub(/^0O?/, '0o')
        end

        def format_octal_zero_only(source)
          source.sub(/^0[Oo]?/, '0')
        end

        def format_hex(source)
          source.sub(/^0X/, '0x')
        end

        def format_binary(source)
          source.sub(/^0B/, '0b')
        end

        def format_decimal(source)
          source.sub(/^0[dD]/, '')
        end
      end
    end
  end
end
