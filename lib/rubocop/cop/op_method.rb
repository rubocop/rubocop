# encoding: utf-8

module Rubocop
  module Cop
    class OpMethod < Cop
      ERROR_MESSAGE = 'When defining the %s operator, name its argument other.'

      BLACKLISTED = [:+@, :-@, :[], :[]=, :<<]

      TARGET_ARGS = s(:args, s(:arg, :other))

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:def, sexp) do |s|
          name, args, _body = *s

          if name !~ /\A\w/ && !BLACKLISTED.include?(name) &&
            args.children.size == 1 && args != TARGET_ARGS
            add_offence(:convention,
                        s.src.line,
                        sprintf(ERROR_MESSAGE, name))
          end
        end
      end
    end
  end
end
