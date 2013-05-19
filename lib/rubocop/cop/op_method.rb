# encoding: utf-8

module Rubocop
  module Cop
    class OpMethod < Cop
      MSG = 'When defining the %s operator, name its argument other.'

      BLACKLISTED = [:+@, :-@, :[], :[]=, :<<]

      TARGET_ARGS = s(:args, s(:arg, :other))

      def inspect(file, source, tokens, ast)
        on_node(:def, ast) do |s|
          name, args, _body = *s

          if name !~ /\A\w/ && !BLACKLISTED.include?(name) &&
            args.children.size == 1 && args != TARGET_ARGS
            add_offence(:convention,
                        s.src.line,
                        sprintf(MSG, name))
          end
        end
      end
    end
  end
end
