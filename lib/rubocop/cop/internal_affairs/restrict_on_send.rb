# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Check for `RESTRICT_ON_SEND` is defined if `on_send` or `after_send` are defined.
      #
      # @example
      #   # bad
      #   class FooCop
      #     def on_send(node)
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class FooCop
      #     RESTRICT_ON_SEND = %i[bad_method].freeze
      #     def on_send(node)
      #       # ...
      #     end
      #   end
      #
      class RestrictOnSend < Base
        MSG = 'Consider defined `RESTRICT_ON_SEND` for optimization.'
        NEED_RESTRICT_ON_SEND = %i[on_send after_send].freeze

        # @!method defined_restrict_on_send?(node)
        def_node_search :defined_restrict_on_send?, '(casgn nil? :RESTRICT_ON_SEND ...)'

        def on_def(node)
          return unless NEED_RESTRICT_ON_SEND.include?(node.method_name)

          class_node = class_node(node)
          add_offense(class_node) unless defined_restrict_on_send?(class_node)
        end

        def class_node(node)
          if node.parent.class_type?
            node.parent
          else
            class_node(node.parent)
          end
        end
      end
    end
  end
end
