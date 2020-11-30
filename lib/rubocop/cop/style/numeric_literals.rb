# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for big numeric literals without _ between groups
      # of digits in them.
      #
      # @example
      #
      #   # bad
      #   1000000
      #   1_00_000
      #   1_0000
      #
      #   # good
      #   1_000_000
      #   1000
      #
      # @example Strict: false (default)
      #
      #   # good
      #   10_000_00 # typical representation of $10,000 in cents
      #
      # @example Strict: true
      #
      #   # bad
      #   10_000_00 # typical representation of $10,000 in cents
      #
      class NumericLiterals < Base
        # The parameter is called MinDigits (meaning the minimum number of
        # digits for which an offense can be registered), but essentially it's
        # a Max parameter (the maximum number of something that's allowed).
        include ConfigurableMax
        include IntegerNode
        extend AutoCorrector

        MSG = 'Use underscores(_) as thousands separator and ' \
              'separate every 3 digits with them.'
        DELIMITER_REGEXP = /[eE.]/.freeze

        def on_int(node)
          check(node)
        end

        def on_float(node)
          check(node)
        end

        private

        def max_parameter_name
          'MinDigits'
        end

        def check(node)
          int = integer_part(node)

          # TODO: handle non-decimal literals as well
          return if int.start_with?('0')
          return unless int.size >= min_digits

          case int
          when /^\d+$/
            return unless (self.max = int.size + 1)

            register_offense(node)
          when /\d{4}/, short_group_regex
            return unless (self.config_to_allow_offenses = { 'Enabled' => false })

            register_offense(node)
          end
        end

        def register_offense(node)
          add_offense(node) do |corrector|
            corrector.replace(node, format_number(node))
          end
        end

        def short_group_regex
          cop_config['Strict'] ? /_\d{1,2}(_|$)/ : /_\d{1,2}_/
        end

        def format_number(node)
          source = node.source.gsub(/\s+/, '')
          int_part, additional_part = source.split(DELIMITER_REGEXP, 2)
          formatted_int = format_int_part(int_part)
          delimiter = source[DELIMITER_REGEXP]

          if additional_part
            formatted_int + delimiter + additional_part
          else
            formatted_int
          end
        end

        # @param int_part [String]
        def format_int_part(int_part)
          int_part = Integer(int_part)
          formatted_int = int_part
                          .abs
                          .to_s
                          .reverse
                          .gsub(/...(?=.)/, '\&_')
                          .reverse
          formatted_int.insert(0, '-') if int_part.negative?
          formatted_int
        end

        def min_digits
          cop_config['MinDigits']
        end
      end
    end
  end
end
