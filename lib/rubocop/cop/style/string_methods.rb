# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method names
      # from the String class.
      class StringMethods < Cop
        include MethodPreference

        MSG = 'Prefer `%s` over `%s`.'.freeze

        def on_send(node)
          _receiver, method_name, *_args = *node
          return unless preferred_methods[method_name]
          add_offense(node, :selector,
                      format(MSG, preferred_method(method_name), method_name))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source))
          end
        end
      end
    end
  end
end
