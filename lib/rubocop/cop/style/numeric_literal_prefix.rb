# encoding: utf-8
# frozen_string_literal: true

require 'pry'

module RuboCop
  module Cop
    module Style
      # This cop checks for octal, hex and binary literals using
      # uppercase prefixes and corrects them to lowercase prefix
      # or no prefix (in case of decimals).
      # eg. for octal use `0o` instead of `0` or `0O`.
      class NumericLiteralPrefix < Cop
        include IntegerNode

        OCTAL_REGEX = /^0O?[0-7]+$/
        HEX_REGEX = /^0X[0-9A-F]+$/
        BINARY_REGEX = /^0B[01]+$/
        DECIMAL_REGEX = /^0[dD][0-9]+$/

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
            corrector.replace(node.source_range, send(:"format_#{type}", node))
          end
        end

        def literal_type(node)
          case integer_part(node)
          when OCTAL_REGEX
            'octal'.freeze
          when HEX_REGEX
            'hex'.freeze
          when BINARY_REGEX
            'binary'.freeze
          when DECIMAL_REGEX
            'decimal'.freeze
          end
        end

        def format_octal(node)
          node.source.sub(/^0O?/, '0o')
        end

        def format_hex(node)
          node.source.sub(/^0X/, '0x')
        end

        def format_binary(node)
          node.source.sub(/^0B/, '0b')
        end

        def format_decimal(node)
          node.source.sub(/^0[dD]/, '')
        end
      end
    end
  end
end
