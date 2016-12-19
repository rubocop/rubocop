# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for big numeric literals without _ between groups
      # of digits in them.
      class NumericLiterals < Cop
        # The parameter is called MinDigits (meaning the minimum number of
        # digits for which an offense can be registered), but essentially it's
        # a Max parameter (the maximum number of something that's allowed).
        include ConfigurableMax
        include IntegerNode

        MSG = 'Separate every 3 digits in the integer portion of a number ' \
              'with underscores(_).'.freeze

        def on_int(node)
          check(node)
        end

        def on_float(node)
          check(node)
        end

        private

        def parameter_name
          'MinDigits'
        end

        def check(node)
          int = integer_part(node)

          # TODO: handle non-decimal literals as well
          return if int.start_with?('0')
          return unless int.size >= min_digits

          case int
          when /^\d+$/
            add_offense(node, :expression) { self.max = int.size + 1 }
          when /\d{4}/, /_\d{1,2}(_|$)/
            add_offense(node, :expression) do
              self.config_to_allow_offenses = { 'Enabled' => false }
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, format_number(node))
          end
        end

        def format_number(node)
          int_part, float_part = node.source.split('.')
          int_part = int_part.to_i
          formatted_int = int_part
                          .abs
                          .to_s
                          .reverse
                          .gsub(/...(?=.)/, '\&_')
                          .reverse
          formatted_int.insert(0, '-') if int_part < 0

          if float_part
            format('%s.%s', formatted_int, float_part)
          else
            formatted_int
          end
        end

        def min_digits
          cop_config['MinDigits']
        end
      end
    end
  end
end
