# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for methods invoked via the :: operator instead
      # of the . operator (like FileUtils::rmdir instead of FileUtils.rmdir).
      class ColonMethodCall < Cop
        MSG = 'Do not use :: for method calls.'

        def on_send(node)
          receiver, _method_name, *_args = *node

          # discard methods with nil receivers and op methods(like [])
          if receiver && node.loc.dot && node.loc.dot.is?('::')
            add_offence(:convention, node.loc.dot, MSG)
            do_autocorrect(node)
          end

          super
        end

        def autocorrect_action(node)
          replace(node.loc.dot, '.')
        end
      end
    end
  end
end
