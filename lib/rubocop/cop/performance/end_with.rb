# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies unnecessary use of a regex where `String#end_with?`
      # would suffice.
      #
      # @example
      #   # bad
      #   'abc'.match?(/bc\Z/)
      #   'abc' =~ /bc\Z/
      #   'abc'.match(/bc\Z/)
      #
      #   # good
      #   'abc'.end_with?('bc')
      class EndWith < Cop
        MSG = 'Use `String#end_with?` instead of a regex match anchored to ' \
              'the end of the string.'.freeze
        SINGLE_QUOTE = "'".freeze

        def_node_matcher :redundant_regex?, <<-PATTERN
          {(send $!nil? {:match :=~ :match?} (regexp (str $#literal_at_end?) (regopt)))
           (send (regexp (str $#literal_at_end?) (regopt)) {:match :=~} $_)}
        PATTERN

        def literal_at_end?(regex_str)
          # is this regexp 'literal' in the sense of only matching literal
          # chars, rather than using metachars like . and * and so on?
          # also, is it anchored at the end of the string?
          regex_str =~ /\A(?:#{LITERAL_REGEX})+\\z\z/
        end

        def on_send(node)
          return unless redundant_regex?(node)

          add_offense(node)
        end

        def autocorrect(node)
          redundant_regex?(node) do |receiver, regex_str|
            receiver, regex_str = regex_str, receiver if receiver.is_a?(String)
            regex_str = regex_str[0..-3] # drop \Z anchor
            regex_str = interpret_string_escapes(regex_str)

            lambda do |corrector|
              new_source = receiver.source + '.end_with?(' +
                           to_string_literal(regex_str) + ')'
              corrector.replace(node.source_range, new_source)
            end
          end
        end
      end
    end
  end
end
