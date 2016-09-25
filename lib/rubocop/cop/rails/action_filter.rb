# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the consistent use of action filters methods.
      #
      # The cop is configurable and the enforce the use of older
      # something_filter methods or the newer something_action methods.
      class ActionFilter < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Prefer `%s` over `%s`.'.freeze

        FILTER_METHODS = [
          :after_filter,
          :append_after_filter,
          :append_around_filter,
          :append_before_filter,
          :around_filter,
          :before_filter,
          :prepend_after_filter,
          :prepend_around_filter,
          :prepend_before_filter,
          :skip_after_filter,
          :skip_around_filter,
          :skip_before_filter,
          :skip_filter
        ].freeze

        ACTION_METHODS = [
          :after_action,
          :append_after_action,
          :append_around_action,
          :append_before_action,
          :around_action,
          :before_action,
          :prepend_after_action,
          :prepend_around_action,
          :prepend_before_action,
          :skip_after_action,
          :skip_around_action,
          :skip_before_action,
          :skip_action_callback
        ].freeze

        def on_block(node)
          method, _args, _body = *node

          check_method_node(method)
        end

        def on_send(node)
          receiver, _method_name, *_args = *node

          check_method_node(node) if receiver.nil?
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source).to_s)
          end
        end

        private

        def check_method_node(node)
          _receiver, method_name, *_args = *node
          return unless offending_method?(method_name)

          add_offense(node, :selector,
                      format(MSG,
                             preferred_method(method_name),
                             method_name))
        end

        def offending_method?(method_name)
          bad_methods.include?(method_name)
        end

        def bad_methods
          style == :action ? FILTER_METHODS : ACTION_METHODS
        end

        def good_methods
          style == :action ? ACTION_METHODS : FILTER_METHODS
        end

        def preferred_method(method)
          good_methods[bad_methods.index(method.to_sym)]
        end
      end
    end
  end
end
