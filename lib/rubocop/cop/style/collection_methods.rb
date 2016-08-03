# encoding: utf-8
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

        MSG = 'Prefer `%s` over `%s`.'.freeze

        def on_block(node)
          method, _args, _body = *node

          check_method_node(method)
        end

        def on_send(node)
          _receiver, _method_name, *args = *node
          return unless args.one? && args.first.block_pass_type?

          check_method_node(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source))
          end
        end

        private

        def check_method_node(node)
          _receiver, method_name, *_args = *node

          return unless preferred_methods[method_name]
          add_offense(node, :selector,
                      format(MSG,
                             preferred_method(method_name),
                             method_name))
        end
      end
    end
  end
end
