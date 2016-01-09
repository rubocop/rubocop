# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies places where a case-insensitive string comparison
      # can better be implemented using `casecmp`.
      #
      # @example
      #   @bad
      #   'abc'.downcase == 'ABC'
      #   'abc'.upcase.eql? 'ABC'
      #
      #   @good
      #   'abc'.casecmp('ABC')
      class Casecmp < Cop
        MSG = 'Use `casecmp` instead of `%s %s`.'.freeze

        def_node_matcher :downcase_eq, <<-END
          (send $(send _ ${:downcase :upcase}) ${:== :eql?} _)
        END

        def on_send(node)
          downcase_eq(node) do |send_downcase, case_method, eq_method|
            range = node.loc.selector.join(send_downcase.loc.selector)
            add_offense(node, range, format(MSG, case_method, eq_method))
          end
        end

        def autocorrect(node)
          receiver, _method, arg = *node
          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            receiver.loc.selector.begin_pos,
                                            arg.loc.begin.begin_pos)

          lambda do |corrector|
            # we want resulting call to be parenthesized
            # if arg already includes one or more sets of parens, don't add more
            # or if method call already used parens, again, don't add more
            if arg.loc.begin.source == '('
              corrector.replace(range, 'casecmp')
              corrector.insert_after(arg.source_range, '.zero?')
            elsif range.source =~ /\(/
              corrector.replace(range, 'casecmp(')
              corrector.insert_after(node.source_range, '.zero?')
            else
              corrector.replace(range, 'casecmp(')
              corrector.insert_after(arg.source_range, ').zero?')
            end
          end
        end
      end
    end
  end
end
