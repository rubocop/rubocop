# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for overriding built-in Active Record methods instead of using
      # callbacks.
      #
      # @example
      #   # bad
      #   class Book < ApplicationRecord
      #     def save
      #       self.title = title.upcase!
      #       super
      #     end
      #   end
      #
      #   # good
      #   class Book < ApplicationRecord
      #     before_save :upcase_title
      #
      #     def upcase_title
      #       self.title = title.upcase!
      #     end
      #   end
      #
      class ActiveRecordOverride < Cop
        MSG =
          'Use %<prefer>s callbacks instead of overriding the Active Record ' \
          'method `%<bad>s`.'.freeze
        BAD_METHODS = %i[create destroy save update].freeze

        def on_def(node)
          method_name = node.method_name
          return unless BAD_METHODS.include?(node.method_name)

          parent_parts = node.parent.node_parts
          parent_class = parent_parts.take_while do |part|
            !part.nil? && part.const_type?
          end.last
          return unless %w[ApplicationRecord ActiveModel::Base]
                        .include?(parent_class.const_name)

          return unless node.descendants.any?(&:zsuper_type?)

          add_offense(node, message: message(method_name))
        end

        private

        def callback_names(method_name)
          names = %w[before_ around_ after_].map do |prefix|
            "`#{prefix}#{method_name}`"
          end

          names[-1] = "or #{names.last}"

          names.join(', ')
        end

        def message(method_name)
          format(MSG, prefer: callback_names(method_name), bad: method_name)
        end
      end
    end
  end
end
