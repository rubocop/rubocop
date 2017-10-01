# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies use of `Regexp#match` or `String#match` in a context
      # where the integral return value of `=~` would do just as well.
      #
      # @example
      #   @bad
      #   do_something if str.match(/regex/)
      #   while regex.match('str')
      #     do_something
      #   end
      #
      #   @good
      #   method(str.match(/regex/))
      #   return regex.match('str')
      class RedundantMatch < Cop
        MSG = 'Use `=~` in places where the `MatchData` returned by ' \
              '`#match` will not be used.'.freeze

        # 'match' is a fairly generic name, so we don't flag it unless we see
        # a string or regexp literal on one side or the other
        def_node_matcher :match_call?, <<-PATTERN
          {(send {str regexp} :match _)
           (send !nil? :match {str regexp})}
        PATTERN

        def_node_matcher :only_truthiness_matters?, <<-PATTERN
          ^({if while until case while_post until_post} equal?(%0) ...)
        PATTERN

        def on_send(node)
          return unless match_call?(node) &&
                        (!node.value_used? || only_truthiness_matters?(node)) &&
                        !(node.parent && node.parent.block_type?)

          add_offense(node)
        end

        def autocorrect(node)
          # Regexp#match can take a second argument, but this cop doesn't
          # register an offense in that case
          return unless node.first_argument.regexp_type?

          new_source =
            node.receiver.source + ' =~ ' + node.first_argument.source

          ->(corrector) { corrector.replace(node.source_range, new_source) }
        end
      end
    end
  end
end
