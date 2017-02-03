# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of methods which skip
      # validations which are listed in
      # http://guides.rubyonrails.org/active_record_validations.html#skipping-validations
      #
      # @example
      #   # bad
      #   Article.first.decrement!(:view_count)
      #   DiscussionBoard.decrement_counter(:post_count, 5)
      #   Article.first.increment!(:view_count)
      #   DiscussionBoard.increment_counter(:post_count, 5)
      #   person.toggle :active
      #   product.touch
      #   Billing.update_all("category = 'authorized', author = 'David'")
      #   user.update_attribute(website: 'example.com')
      #   user.update_columns(last_request_at: Time.current)
      #   Post.update_counters 5, comment_count: -1, action_count: 1
      #
      #   # good
      #   user.update_attributes(website: 'example.com')
      class SkipsModelValidations < Cop
        MSG = 'Avoid using `%s` because it skips validations.'.freeze

        def on_send(node)
          return unless blacklist.include?(node.method_name.to_s)

          add_offense(node, :selector)
        end

        private

        def message(node)
          format(MSG, node.method_name)
        end

        def blacklist
          cop_config['Blacklist'] || []
        end
      end
    end
  end
end
