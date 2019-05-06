# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of consistent method names
      # from the String class.
      #
      # @example
      #   # bad
      #   'name'.intern
      #   'var'.unfavored_method
      #
      #   # good
      #   'name'.to_sym
      #   'var'.preferred_method
      class StringMethods < Cop
        include MethodPreference

        MSG = 'Prefer `%<prefer>s` over `%<current>s`.'

        def on_send(node)
          return unless preferred_method(node.method_name)

          add_offense(node, location: :selector)
        end
        alias on_csend on_send

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.method_name))
          end
        end

        private

        def message(node)
          format(MSG,
                 prefer: preferred_method(node.method_name),
                 current: node.method_name)
        end
      end
    end
  end
end
