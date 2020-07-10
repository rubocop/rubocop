# frozen_string_literal: true

require 'parser/current'

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant arguments to methods.
      # Method names & arguments can be configured like:
      #
      # RedundantArguments:
      #   join: ''
      #   split: ' '
      #   foo: 2
      #
      # Limitations:
      # 1. This cop matches for method names only and hence cannot tell apart
      #    methods with same name in different classes.
      # 2. This cop is limited to methods with single parameter.
      #
      # @example
      #   # bad
      #
      #   array.join('')
      #   [1, 2, 3].join("")
      #   string.split(" ")
      #   "first\nsecond".split(" ")
      #   A.foo(2)
      #
      #   # good
      #   array.join
      #   [1, 2, 3].join
      #   string.split
      #   "first second".split
      #   A.foo
      class RedundantArguments < Cop
        MSG = 'Argument is redundant.'

        def on_send(node)
          return unless redundant_argument?(node)

          add_offense(node)
        end

        private

        def redundant_argument?(node)
          redundant_argument = redundant_arg_for_method(node.method_name.to_s)
          return false if redundant_argument.nil?

          node.arguments.first == redundant_argument
        end

        def redundant_arg_for_method(method_name)
          return nil unless cop_config['RedundantArguments'].key?(method_name)

          @mem ||= {}
          @mem[method_name] ||= begin
                                  arg = cop_config['RedundantArguments'].fetch(method_name)
                                  buffer = Parser::Source::Buffer.new('(string)', 1)
                                  buffer.source = arg.inspect
                                  builder = RuboCop::AST::Builder.new
                                  Parser::CurrentRuby.new(builder).parse(buffer)
                                end
        end
      end
    end
  end
end
