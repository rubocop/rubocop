# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that `if` and `only` (or `except`) are not used together
      # as options of `skip_*` action filter.
      #
      # The `if` option will be ignored when `if` and `only` are used together.
      # Similarly, the `except` option will be ignored when `if` and `except`
      # are used together.
      #
      # @example
      #   # bad
      #   class MyPageController < ApplicationController
      #     skip_before_action :login_required,
      #       only: :show, if: :trusted_origin?
      #   end
      #
      #   # good
      #   class MyPageController < ApplicationController
      #     skip_before_action :login_required,
      #       if: -> { trusted_origin? && action_name == "show" }
      #   end
      #
      # @example
      #   # bad
      #   class MyPageController < ApplicationController
      #     skip_before_action :login_required,
      #       except: :admin, if: :trusted_origin?
      #   end
      #
      #   # good
      #   class MyPageController < ApplicationController
      #     skip_before_action :login_required,
      #       if: -> { trusted_origin? && action_name != "admin" }
      #   end
      #
      # @see https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-_normalize_callback_options
      class IgnoredSkipActionFilterOption < Cop
        MSG = <<-MSG.strip_indent.chomp.freeze
          `%<ignore>s` option will be ignored when `%<prefer>s` and `%<ignore>s` are used together.
        MSG

        FILTERS = %w[
          :skip_after_action
          :skip_around_action
          :skip_before_action
          :skip_action_callback
        ].freeze

        def_node_matcher :filter_options, <<-PATTERN
          (send
            nil?
            {#{FILTERS.join(' ')}}
            _
            $_)
        PATTERN

        def on_send(node)
          options = filter_options(node)
          return unless options
          return unless options.hash_type?

          options = options_hash(options)

          if if_and_only?(options)
            add_offense(options[:if],
                        message: format(MSG, prefer: :only, ignore: :if))
          elsif if_and_except?(options)
            add_offense(options[:except],
                        message: format(MSG, prefer: :if, ignore: :except))
          end
        end

        private

        def options_hash(options)
          options.pairs
                 .select { |pair| pair.key.sym_type? }
                 .map { |pair| [pair.key.value, pair] }.to_h
        end

        def if_and_only?(options)
          options.key?(:if) && options.key?(:only)
        end

        def if_and_except?(options)
          options.key?(:if) && options.key?(:except)
        end
      end
    end
  end
end
