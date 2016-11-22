# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for methods invoked via the :: operator instead
      # of the . operator (like FileUtils::rmdir instead of FileUtils.rmdir).
      class ColonMethodCall < Cop
        MSG = 'Do not use `::` for method calls.'.freeze

        def_node_matcher :java_type_node?, <<-PATTERN
          (send
            (const nil :Java)
            {:boolean :byte :char :double :float :int :long :short})
        PATTERN

        def on_send(node)
          # ignore Java interop code like Java::int
          return if java_type_node?(node)

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
