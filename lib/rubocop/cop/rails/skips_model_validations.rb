# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of methods which skip
      # validations which are listed in
      # https://guides.rubyonrails.org/active_record_validations.html#skipping-validations
      #
      # Methods may be ignored from this rule by configuring a `Whitelist`.
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
      #   user.update_attribute(:website, 'example.com')
      #   user.update_columns(last_request_at: Time.current)
      #   Post.update_counters 5, comment_count: -1, action_count: 1
      #
      #   # good
      #   user.update(website: 'example.com')
      #   FileUtils.touch('file')
      #
      # @example Whitelist: ["touch"]
      #   # bad
      #   DiscussionBoard.decrement_counter(:post_count, 5)
      #   DiscussionBoard.increment_counter(:post_count, 5)
      #   person.toggle :active
      #
      #   # good
      #   user.touch
      #
      class SkipsModelValidations < Cop
        MSG = 'Avoid using `%<method>s` because it skips validations.'.freeze

        METHODS_WITH_ARGUMENTS = %w[decrement!
                                    decrement_counter
                                    increment!
                                    increment_counter
                                    toggle!
                                    update_all
                                    update_attribute
                                    update_column
                                    update_columns
                                    update_counters].freeze

        def_node_matcher :good_touch?, <<-PATTERN
          (send (const nil? :FileUtils) :touch ...)
        PATTERN

        def on_send(node)
          return if whitelist.include?(node.method_name.to_s)
          return unless blacklist.include?(node.method_name.to_s)

          _receiver, method_name, *args = *node

          if METHODS_WITH_ARGUMENTS.include?(method_name.to_s) && args.empty?
            return
          end

          return if good_touch?(node)

          add_offense(node, location: :selector)
        end
        alias on_csend on_send

        private

        def message(node)
          format(MSG, method: node.method_name)
        end

        def blacklist
          cop_config['Blacklist'] || []
        end

        def whitelist
          cop_config['Whitelist'] || []
        end
      end
    end
  end
end
