# encoding: utf-8

module Rubocop
  module Cop
    class OpMethod < Cop
      MSG = 'When defining the %s operator, name its argument other.'

      BLACKLISTED = [:+@, :-@, :[], :[]=, :<<]

      TARGET_ARGS = s(:args, s(:arg, :other))

      def on_def(node)
        name, args, _body = *node

        if name !~ /\A\w/ && !BLACKLISTED.include?(name) &&
            args.children.size == 1 && args != TARGET_ARGS
          add_offence(:convention,
                      node.loc,
                      sprintf(MSG, name))
        end

        super
      end
    end
  end
end
