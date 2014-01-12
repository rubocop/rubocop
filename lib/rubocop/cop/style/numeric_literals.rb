# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for big numeric literals without _ between groups
      # of digits in them.
      class NumericLiterals < Cop
        # The parameter is called MinDigits (meaning the minimum number of
        # digits for which an offence can be registered), but essentially it's
        # a Max parameter (the maximum number of something that's allowed).
        include ConfigurableMax

        MSG = 'Separate every 3 digits in the integer portion of a number ' \
          'with underscores(_).'

        def on_int(node)
          check(node)
        end

        def on_fload(node)
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

          if int.size >= min_digits
            case int
            when /^\d+$/
              add_offence(node, :expression) { self.max = int.size }
            when /\d{4}/, /_\d{1,2}_/
              add_offence(node, :expression) do
                self.config_to_allow_offences = { 'Enabled' => false }
              end
            end
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            int = node.loc.expression.source.to_i
            formatted_int = int
              .abs
              .to_s
              .reverse
              .gsub(/...(?=.)/, '\&_')
              .reverse
            formatted_int.insert(0, '-') if int < 0
            corrector.replace(node.loc.expression, formatted_int)
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
