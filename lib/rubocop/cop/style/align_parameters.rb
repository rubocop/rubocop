# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call are
      # aligned.
      class AlignParameters < Cop
        include AutocorrectAlignment

        MSG = 'Align the parameters of a method call if they span ' \
              'more than one line.'

        def on_send(node)
          _receiver, method, *args = *node

          return if method == :[]=
          return if args.size <= 1

          check_alignment(args, base_column(node, args))
        end

        private

        def fixed_indentation?
          cop_config['EnforcedStyle'] == 'with_fixed_indentation'
        end

        def base_column(node, args)
          if fixed_indentation?
            node.loc.column + 2
          else
            args.first.loc.column
          end
        end
      end
    end
  end
end
