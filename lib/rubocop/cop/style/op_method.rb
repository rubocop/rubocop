# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop makes sure that certain binary operator methods have their
      # sole  parameter named `other`.
      #
      # @example
      #
      #   # bad
      #   def +(amount); end
      #
      #   # good
      #   def +(other); end
      class OpMethod < Cop
        MSG = 'When defining the `%s` operator, ' \
              'name its argument `other`.'.freeze

        OP_LIKE_METHODS = [:eql?, :equal?].freeze

        BLACKLISTED = [:+@, :-@, :[], :[]=, :<<, :`].freeze

        TARGET_ARGS = [s(:args, s(:arg, :other)),
                       s(:args, s(:arg, :_other))].freeze

        def on_def(node)
          name, args, _body = *node
          return unless op_method?(name) &&
                        args.children.one? &&
                        !TARGET_ARGS.include?(args)

          add_offense(args.children[0], :expression, format(MSG, name))
        end

        def op_method?(name)
          return false if BLACKLISTED.include?(name)
          name !~ /\A\w/ || OP_LIKE_METHODS.include?(name)
        end
      end
    end
  end
end
