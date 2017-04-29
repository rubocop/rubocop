# frozen_string_literal: true

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
        MSG = 'Use `%<receiver>s.%<method>s(%<combined_args>s)` ' \
              'instead of `%<original_code>s`.'.freeze

        def on_or(node)
          receiver,
          method,
          first_call_args,
          second_call_args = process_source(node)

          return unless receiver && second_call_args.all?(&:pure?)

          combined_args = combine_args(first_call_args, second_call_args)

          add_offense_for_double_call(node, receiver, method, combined_args)
        end

        def autocorrect(node)
          _receiver, _method,
          first_call_args, second_call_args = process_source(node)

          combined_args = combine_args(first_call_args, second_call_args)
          first_argument = first_call_args.first.loc.expression
          last_argument = second_call_args.last.loc.expression
          range = first_argument.join(last_argument)

          lambda do |corrector|
            corrector.replace(range, combined_args)
          end
        end

        private

        def process_source(node)
          if check_for_active_support_aliases?
            check_with_active_support_aliases(node)
          else
            two_start_end_with_calls(node)
          end
        end

        def combine_args(first_call_args, second_call_args)
          (first_call_args + second_call_args).map(&:source).join(', ')
        end

        def add_offense_for_double_call(node, receiver, method, combined_args)
          add_offense(node,
                      :expression,
                      format(
                        MSG,
                        receiver: receiver.source,
                        method: method,
                        combined_args: combined_args,
                        original_code: node.source
                      ))
        end

        def check_for_active_support_aliases?
          cop_config['IncludeActiveSupportAliases']
        end

        def_node_matcher :two_start_end_with_calls, <<-END
          (or
            (send $_recv [{:start_with? :end_with?} $_method] $...)
            (send _recv _method $...))
        END

        def_node_matcher :check_with_active_support_aliases, <<-END
          (or
            (send $_recv
                    [{:start_with? :starts_with? :end_with? :ends_with?} $_method]
                  $...)
            (send _recv _method $...))
        END
      end
    end
  end
end
