# frozen_string_literal: true

require 'parser/current'

module RuboCop
  module Cop
    module Style
      # This cop checks for a redundant argument passed to certain methods.
      #
      # Limitations:
      #
      # 1. This cop matches for method names only and hence cannot tell apart
      #    methods with same name in different classes.
      # 2. This cop is limited to methods with single parameter.
      # 3. This cop is unsafe if certain special global variables (e.g. `$;`, `$/`) are set.
      #    That depends on the nature of the target methods, of course.
      #
      # Method names and their redundant arguments can be configured like this:
      #
      # Methods:
      #   join: ''
      #   split: ' '
      #   chomp: "\n"
      #   chomp!: "\n"
      #   foo: 2
      #
      # @example
      #   # bad
      #   array.join('')
      #   [1, 2, 3].join("")
      #   string.split(" ")
      #   "first\nsecond".split(" ")
      #   string.chomp("\n")
      #   string.chomp!("\n")
      #   A.foo(2)
      #
      #   # good
      #   array.join
      #   [1, 2, 3].join
      #   string.split
      #   "first second".split
      #   string.chomp
      #   string.chomp!
      #   A.foo
      class RedundantArgument < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Argument %<arg>s is redundant because it is implied by default.'

        def on_send(node)
          return if node.receiver.nil?
          return if node.arguments.count != 1
          return unless redundant_argument?(node)

          add_offense(node, message: format(MSG, arg: node.arguments.first.source)) do |corrector|
            corrector.remove(argument_range(node))
          end
        end

        private

        def redundant_argument?(node)
          redundant_argument = redundant_arg_for_method(node.method_name.to_s)
          return false if redundant_argument.nil?

          node.arguments.first == redundant_argument
        end

        def redundant_arg_for_method(method_name)
          return nil unless cop_config['Methods'].key?(method_name)

          @mem ||= {}
          @mem[method_name] ||=
            begin
              arg = cop_config['Methods'].fetch(method_name)
              buffer = Parser::Source::Buffer.new('(string)', 1)
              buffer.source = arg.inspect
              builder = RuboCop::AST::Builder.new
              Parser::CurrentRuby.new(builder).parse(buffer)
            end
        end

        def argument_range(node)
          if node.parenthesized?
            range_between(node.loc.begin.begin_pos, node.loc.end.end_pos)
          else
            range_with_surrounding_space(range: node.first_argument.source_range, newlines: false)
          end
        end
      end
    end
  end
end
