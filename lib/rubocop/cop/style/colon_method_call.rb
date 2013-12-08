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
          return unless receiver && node.loc.dot && node.loc.dot.is?('::')
          return if allowed_name(_method_name.to_s)

          add_offence(node, :dot)
        end

        def allowed_name(method_name)
          method_name.match(/^[A-Z]/)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.dot, '.')
          end
        end
      end
    end
  end
end
