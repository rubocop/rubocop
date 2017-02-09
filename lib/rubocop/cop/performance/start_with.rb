# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies unnecessary use of a regex where
      # `String#start_with?` would suffice.
      #
      # @example
      #   @bad
      #   'abc' =~ /\Aab/
      #   'abc'.match(/\Aab/)
      #
      #   @good
      #   'abc' =~ /ab/
      #   'abc' =~ /\A\w*/
      class StartWith < Cop
        MSG = 'Use `String#start_with?` instead of a regex match anchored to ' \
              'the beginning of the string.'.freeze
        SINGLE_QUOTE = "'".freeze

        def_node_matcher :redundant_regex?, <<-END
          {(send $!nil {:match :=~} (regexp (str $#literal_at_start?) (regopt)))
           (send (regexp (str $#literal_at_start?) (regopt)) {:match :=~} $_)}
        END

        def literal_at_start?(regex_str)
          # is this regexp 'literal' in the sense of only matching literal
          # chars, rather than using metachars like . and * and so on?
          # also, is it anchored at the start of the string?
          # (tricky: \s, \d, and so on are metacharacters, but other characters
          #  escaped with a slash are just literals. LITERAL_REGEX takes all
          #  that into account.)
          regex_str =~ /\A\\A(?:#{LITERAL_REGEX})+\z/
        end

        def on_send(node)
          return unless redundant_regex?(node)

          add_offense(node, :expression)
        end

        def autocorrect(node)
          redundant_regex?(node) do |receiver, regex_str|
            receiver, regex_str = regex_str, receiver if receiver.is_a?(String)
            regex_str = regex_str[2..-1] # drop \A anchor
            regex_str = interpret_string_escapes(regex_str)

            lambda do |corrector|
              new_source = receiver.source + '.start_with?(' +
                           to_string_literal(regex_str) + ')'
              corrector.replace(node.source_range, new_source)
            end
          end
        end
      end
    end
  end
end
