# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for methods invoked via the :: operator instead
      # of the . operator (like FileUtils::rmdir instead of FileUtils.rmdir).
      class ColonMethodCall < Cop
        MSG = 'Do not use `::` for method calls.'.freeze

        JAVA_TYPES = [:byte, :boolean, :byte, :short, :char,
                      :int, :long, :float, :double].freeze

        JAVA_TYPE_NODES =
          JAVA_TYPES.map { |t| s(:send, s(:const, nil, :Java), t) }

        def on_send(node)
          # ignore Java interop code like Java::int
          return if JAVA_TYPE_NODES.include?(node)

          receiver, method_name, *_args = *node

          # discard methods with nil receivers and op methods(like [])
          return unless receiver && node.loc.dot && node.loc.dot.is?('::')
          return if allowed_name(method_name.to_s)

          add_offense(node, :dot)
        end

        def allowed_name(method_name)
          method_name.match(/^[A-Z]/)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.dot, '.') }
        end
      end
    end
  end
end
