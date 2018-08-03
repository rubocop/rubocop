# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where a case-insensitive string comparison
      # can better be implemented using `casecmp`.
      #
      # @example
      #   # bad
      #   str.downcase == 'abc'
      #   str.upcase.eql? 'ABC'
      #   'abc' == str.downcase
      #   'ABC'.eql? str.upcase
      #   str.downcase == str.downcase
      #
      #   # good
      #   str.casecmp('ABC').zero?
      #   'abc'.casecmp(str).zero?
      class Casecmp < Cop
        MSG = 'Use `%<good>s` instead of `%<bad>s`.'.freeze
        CASE_METHODS = %i[downcase upcase].freeze

        def_node_matcher :downcase_eq, <<-PATTERN
          (send
            $(send _ ${:downcase :upcase})
            ${:== :eql? :!=}
            ${str (send _ {:downcase :upcase} ...) (begin str)})
        PATTERN

        def_node_matcher :eq_downcase, <<-PATTERN
          (send
            {str (send _ {:downcase :upcase} ...) (begin str)}
            ${:== :eql? :!=}
            $(send _ ${:downcase :upcase}))
        PATTERN

        def_node_matcher :downcase_downcase, <<-PATTERN
          (send
            $(send _ ${:downcase :upcase})
            ${:== :eql? :!=}
            $(send _ ${:downcase :upcase}))
        PATTERN

        def on_send(node)
          return unless downcase_eq(node) || eq_downcase(node)
          return unless (parts = take_method_apart(node))

          _, _, arg, variable = parts
          good_method = build_good_method(arg, variable)

          add_offense(
            node,
            message: format(MSG, good: good_method, bad: node.source)
          )
        end

        def autocorrect(node)
          return unless (parts = take_method_apart(node))

          receiver, method, arg, variable = parts

          correction(node, receiver, method, arg, variable)
        end

        private

        def take_method_apart(node)
          if downcase_downcase(node)
            receiver, method, rhs = *node
            arg, = *rhs
          elsif downcase_eq(node)
            receiver, method, arg = *node
          elsif eq_downcase(node)
            arg, method, receiver = *node
          else
            return
          end

          variable, = *receiver

          [receiver, method, arg, variable]
        end

        def correction(node, _receiver, method, arg, variable)
          lambda do |corrector|
            corrector.insert_before(node.loc.expression, '!') if method == :!=

            replacement = build_good_method(arg, variable)

            corrector.replace(node.loc.expression, replacement)
          end
        end

        def build_good_method(arg, variable)
          # We want resulting call to be parenthesized
          # if arg already includes one or more sets of parens, don't add more
          # or if method call already used parens, again, don't add more
          if arg.send_type? || !parentheses?(arg)
            "#{variable.source}.casecmp(#{arg.source}).zero?"
          else
            "#{variable.source}.casecmp#{arg.source}.zero?"
          end
        end
      end
    end
  end
end
