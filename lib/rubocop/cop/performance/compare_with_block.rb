# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where `sort { |a, b| a.foo <=> b.foo }`
      # can be replaced by `sort_by(&:foo)`.
      # This cop also checks `max` and `min` methods.
      #
      # @example
      #   # bad
      #   array.sort { |a, b| a.foo <=> b.foo }
      #   array.max { |a, b| a.foo <=> b.foo }
      #   array.min { |a, b| a.foo <=> b.foo }
      #   array.sort { |a, b| a[:foo] <=> b[:foo] }
      #
      #   # good
      #   array.sort_by(&:foo)
      #   array.sort_by { |v| v.foo }
      #   array.sort_by do |var|
      #     var.foo
      #   end
      #   array.max_by(&:foo)
      #   array.min_by(&:foo)
      #   array.sort_by { |a| a[:foo] }
      class CompareWithBlock < Cop
        MSG = 'Use `%s_by%s` instead of ' \
              '`%s { |%s, %s| %s <=> %s }`.'.freeze

        def_node_matcher :compare?, <<-PATTERN
          (block
            $(send _ {:sort :min :max})
            (args (arg $_a) (arg $_b))
            $send)
        PATTERN

        def_node_matcher :replaceable_body?, <<-PATTERN
          (send
            (send (lvar %1) $_method $...)
            :<=>
            (send (lvar %2) _method $...))
        PATTERN

        def on_block(node)
          compare?(node) do |send, var_a, var_b, body|
            replaceable_body?(body, var_a, var_b) do |method, args_a, args_b|
              return unless slow_compare?(method, args_a, args_b)
              range = compare_range(send, node)

              add_offense(
                node,
                location: range,
                message: message(send, method, var_a, var_b, args_a)
              )
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            send, var_a, var_b, body = compare?(node)
            method, arg, = replaceable_body?(body, var_a, var_b)
            replacement =
              if method == :[]
                "#{send.method_name}_by { |a| a[#{arg.first.source}] }"
              else
                "#{send.method_name}_by(&:#{method})"
              end
            corrector.replace(compare_range(send, node),
                              replacement)
          end
        end

        private

        def slow_compare?(method, args_a, args_b)
          return false unless args_a == args_b
          if method == :[]
            return false unless args_a.size == 1
            key = args_a.first
            return false unless %i[sym str int].include?(key.type)
          else
            return false unless args_a.empty?
          end
          true
        end

        def message(send, method, var_a, var_b, args)
          compare_method = send.method_name
          if method == :[]
            key = args.first
            instead = " { |a| a[#{key.source}] }"
            str_a = "#{var_a}[#{key.source}]"
            str_b = "#{var_b}[#{key.source}]"
          else
            instead = "(&:#{method})"
            str_a = "#{var_a}.#{method}"
            str_b = "#{var_b}.#{method}"
          end
          format(MSG, compare_method, instead,
                 compare_method, var_a, var_b,
                 str_a, str_b)
        end

        def compare_range(send, node)
          range_between(send.loc.selector.begin_pos, node.loc.end.end_pos)
        end
      end
    end
  end
end
