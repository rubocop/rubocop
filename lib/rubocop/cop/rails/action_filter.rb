# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the consistent use of action filter methods.
      #
      # The cop is configurable and can enforce the use of the older
      # something_filter methods or the newer something_action methods.
      #
      # If the TargetRailsVersion is set to less than 4.0, the cop will enforce
      # the use of filter methods.
      class ActionFilter < Cop
        extend TargetRailsVersion
        include ConfigurableEnforcedStyle

        MSG = 'Prefer `%s` over `%s`.'.freeze

        FILTER_METHODS = %i[
          after_filter
          append_after_filter
          append_around_filter
          append_before_filter
          around_filter
          before_filter
          prepend_after_filter
          prepend_around_filter
          prepend_before_filter
          skip_after_filter
          skip_around_filter
          skip_before_filter
          skip_filter
        ].freeze

        ACTION_METHODS = %i[
          after_action
          append_after_action
          append_around_action
          append_before_action
          around_action
          before_action
          prepend_after_action
          prepend_around_action
          prepend_before_action
          skip_after_action
          skip_around_action
          skip_before_action
          skip_action_callback
        ].freeze

        minimum_target_rails_version 4.0

        def on_block(node)
          method, _args, _body = *node

          check_method_node(method)
        end

        def on_send(node)
          check_method_node(node) unless node.receiver
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              preferred_method(node.loc.selector.source).to_s)
          end
        end

        private

        def check_method_node(node)
          return unless bad_methods.include?(node.method_name)

          add_offense(node, :selector)
        end

        def message(node)
          format(MSG, preferred_method(node.method_name), node.method_name)
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
