# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop enforces the consistent use of action filters methods.
      #
      # The cop is configurable and the enforce the use of older
      # something_filter methods or the newer something_action methods.
      class ActionFilter < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Prefer `%s` over `%s`.'

        FILTER_METHODS = [:before_filter, :skip_before_filter,
                          :after_filter, :around_filter]

        ACTION_METHODS = [:before_action, :skip_before_action,
                          :after_action, :around_action]

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
                             method_name)
                     )
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
