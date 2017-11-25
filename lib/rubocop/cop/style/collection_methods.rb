# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method names
      # from the Enumerable module.
      #
      # Unfortunately we cannot actually know if a method is from
      # Enumerable or not (static analysis limitation), so this cop
      # can yield some false positives.
      class CollectionMethods < Cop
        include MethodPreference

        MSG = 'Prefer `%<prefer>s` over `%<current>s`.'.freeze

        def on_block(node)
          check_method_node(node.send_node)
        end

        def on_send(node)
          return unless node.arguments.one? &&
                        node.first_argument.block_pass_type?

          check_method_node(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source))
          end
        end

        private

        def message(node)
          format(MSG,
                 prefer: preferred_method(node.method_name),
                 current: node.method_name)
        end

        def check_method_node(node)
          return unless preferred_methods[node.method_name]

          add_offense(node, location: :selector)
        end
      end
    end
  end
end
