# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that certain operator methods have their sole
      # parameter named *other*.
      class OpMethod < Cop
        MSG = 'When defining the %s operator, name its argument *other*.'

        BLACKLISTED = [:+@, :-@, :[], :[]=, :<<]

        TARGET_ARGS = s(:args, s(:arg, :other))

        def on_def(node)
          name, args, _body = *node

          if name !~ /\A\w/ && !BLACKLISTED.include?(name) &&
              args.children.size == 1 && args != TARGET_ARGS
            add_offence(args.children[0], :expression,
                        sprintf(MSG, name))
          end
        end
      end
    end
  end
end
