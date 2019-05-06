# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that methods specified in the filter's `only` or
      # `except` options are defined within the same class or module.
      #
      # You can technically specify methods of superclass or methods added by
      # mixins on the filter, but these can confuse developers. If you specify
      # methods that are defined in other classes or modules, you should
      # define the filter in that class or module.
      #
      # If you rely on behaviour defined in the superclass actions, you must
      # remember to invoke `super` in the subclass actions.
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
      #
      # @example
      #   # bad
      #   module FooMixin
      #     extend ActiveSupport::Concern
      #
      #     included do
      #       before_action proc { authenticate }, only: :foo
      #     end
      #   end
      #
      #   # good
      #   module FooMixin
      #     extend ActiveSupport::Concern
      #
      #     included do
      #       before_action proc { authenticate }, only: :foo
      #     end
      #
      #     def foo
      #       # something
      #     end
      #   end
      #
      # @example
      #   class ContentController < ApplicationController
      #     def update
      #       @content.update(content_attributes)
      #     end
      #   end
      #
      #   class ArticlesController < ContentController
      #     before_action :load_article, only: [:update]
      #
      #     # the cop requires this method, but it relies on behaviour defined
      #     # in the superclass, so needs to invoke `super`
      #     def update
      #       super
      #     end
      #
      #     private
      #
      #     def load_article
      #       @content = Article.find(params[:article_id])
      #     end
      #   end
      class LexicallyScopedActionFilter < Cop
        MSG = '%<action>s not explicitly defined on the %<type>s.'

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

          parent = node.each_ancestor(:class, :module).first
          return unless parent

          block = parent.each_child_node(:begin).first
          return unless block

          defined_methods = block.each_child_node(:def).map(&:method_name)
          methods = array_values(methods_node).reject do |method|
            defined_methods.include?(method)
          end

          message = message(methods, parent)
          add_offense(node, message: message) unless methods.empty?
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

        # @param methods [Array<String>]
        # @param parent [RuboCop::AST::Node]
        # @return [String]
        def message(methods, parent)
          if methods.size == 1
            format(MSG,
                   action: "`#{methods[0]}` is",
                   type: parent.type)
          else
            format(MSG,
                   action: "`#{methods.join('`, `')}` are",
                   type: parent.type)
          end
        end
      end
    end
  end
end
