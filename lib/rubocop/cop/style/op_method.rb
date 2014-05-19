# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that certain operator methods have their sole
      # parameter named `other`.
      class OpMethod < Cop
        MSG = 'When defining the `%s` operator, name its argument `other`.'
        BLACKLISTED = [:+@, :-@, :[], :[]=, :<<]
        TARGET_ARGS = [s(:args, s(:arg, :other)), s(:args, s(:arg, :_other))]
        private_constant :MSG, :BLACKLISTED, :TARGET_ARGS

        def on_def(node)
          name, args, _body = *node
          return unless name !~ /\A\w/ && !BLACKLISTED.include?(name) &&
            args.children.size == 1 && !TARGET_ARGS.include?(args)

          add_offense(args.children[0], :expression, format(MSG, name))
        end
      end
    end
  end
end
