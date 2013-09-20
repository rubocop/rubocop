# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for big numeric literals without _ between groups
      # of digits in them.
      class NumericLiterals < Cop
        MSG = 'Separate every 3 digits in the integer portion of a number' \
          'with underscores(_).'

        def min_digits
          cop_config['MinDigits']
        end

        def enough_digits?(number)
          number.to_s.size >= min_digits
        end

        def on_int(node)
          check(node)
        end

        def on_fload(node)
          check(node)
        end

        def check(node)
          value, = *node

          if enough_digits?(value)
            int = integer_part(node)

            # TODO: handle non-decimal literals as well
            return if int.start_with?('0')

            if int =~ /\d{4}/ || int =~ /_\d{1,2}_/
              convention(node, :expression)
            end
          end
        end

        def integer_part(node)
          node.loc.expression.source.split('.').first
        end
      end
    end
  end
end
