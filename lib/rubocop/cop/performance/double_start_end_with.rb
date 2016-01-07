# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop checks for double `#start_with?` or `#end_with?` calls
      # separated by `||`. In some cases such calls can be replaced
      # with an single `#start_with?`/`#end_with?` call.
      #
      # @example
      #
      #   @bad
      #   str.start_with?("a") || str.start_with?(Some::CONST)
      #   str.start_with?("a", "b") || str.start_with?("c")
      #   var1 = ...
      #   var2 = ...
      #   str.end_with?(var1) || str.end_with?(var2)
      #
      #   @good
      #   str.start_with?("a", Some::CONST)
      #   str.start_with?("a", "b", "c")
      #   var1 = ...
      #   var2 = ...
      #   str.end_with?(var1, var2)
      class DoubleStartEndWith < Cop
        MSG = 'Use `%{receiver}.%{method}(%{combined_args})` ' \
              'instead of `%{original_code}`.'

        def on_or(node)
          receiver,
          method,
          first_call_args,
          second_call_args = two_start_end_with_calls(node)

          if receiver && second_call_args.all?(&:pure?)
            add_offense(
              node,
              :expression,
              format(
                MSG,
                receiver: receiver.source,
                method: method,
                combined_args: combine_args(first_call_args, second_call_args),
                original_code: node.source
              )
            )
          end
        end

        private

        def combine_args(first_call_args, second_call_args)
          (first_call_args + second_call_args).map(&:source).join(', ')
        end

        def_node_matcher :two_start_end_with_calls, <<-END
          (or
            (send $_recv [{:start_with? :end_with?} $_method] $...)
            (send _recv _method $...))
        END
      end
    end
  end
end
