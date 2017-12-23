# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that methods specified in the filter's `only`
      # or `except` options are explicitly defined in the controller.
      #
      # You can specify methods of superclass or methods added by mixins
      # on the filter, but these confuse developers. If you specify methods
      # where are defined on another controller, you should define the filter
      # in that controller.
      #
      # @example
      #   # bad
      #   class LoginController < ApplicationController
      #     before_action :require_login, only: %i[index settings logout]
      #
      #     def index
      #     end
      #   end
      #
      #   # good
      #   class LoginController < ApplicationController
      #     before_action :require_login, only: %i[index settings logout]
      #
      #     def index
      #     end
      #
      #     def settings
      #     end
      #
      #     def logout
      #     end
      #   end
      class LexicallyScopedActionFilter < Cop
        MSG = '%<action>s not explicitly defined on the controller.'.freeze

        FILTERS = %w[
          :after_action
          :append_after_action
          :append_around_action
          :append_before_action
          :around_action
          :before_action
          :prepend_after_action
          :prepend_around_action
          :prepend_before_action
          :skip_after_action
          :skip_around_action
          :skip_before_action
          :skip_action_callback
        ].freeze

        def_node_matcher :only_or_except_filter_methods, <<-PATTERN
          (send
            nil?
            {#{FILTERS.join(' ')}}
            _
            (hash
              (pair
                (sym {:only :except})
                $_)))
        PATTERN

        def on_send(node)
          methods_node = only_or_except_filter_methods(node)
          return unless methods_node

          defined_methods = node.parent.each_child_node(:def).map(&:method_name)
          methods = array_values(methods_node).reject do |method|
            defined_methods.include?(method)
          end

          add_offense(node, message: message(methods)) unless methods.empty?
        end

        private

        # @param node [RuboCop::AST::Node]
        # @return [Array<Symbol>]
        def array_values(node) # rubocop:disable Metrics/MethodLength
          case node.type
          when :str
            [node.str_content.to_sym]
          when :sym
            [node.value]
          when :array
            node.values.map do |v|
              case v.type
              when :str
                v.str_content.to_sym
              when :sym
                v.value
              end
            end.compact
          else
            []
          end
        end

        def message(methods)
          if methods.size == 1
            format(MSG, action: "`#{methods[0]}` is")
          else
            format(MSG, action: "`#{methods.join('`, `')}` are")
          end
        end
      end
    end
  end
end
