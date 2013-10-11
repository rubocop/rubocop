# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for big numeric literals without _ between groups
      # of digits in them.
      class NumericLiterals < Cop
        MSG = 'Separate every 3 digits in the integer portion of a number' \
          'with underscores(_).'

        def on_int(node)
          check(node)
        end

        def on_fload(node)
          check(node)
        end

        private

        def check(node)
          int = integer_part(node)

          if int.size >= min_digits
            # TODO: handle non-decimal literals as well
            return if int.start_with?('0')

            if int =~ /\d{4}/ || int =~ /_\d{1,2}_/
              convention(node, :expression)
            end
          end
        end

        def integer_part(node)
          node.loc.expression.source.sub(/^[+-]/, '').split('.').first
        end

        def min_digits
          cop_config['MinDigits']
        end
      end
    end
  end
end
