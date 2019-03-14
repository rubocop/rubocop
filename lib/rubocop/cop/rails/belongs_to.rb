# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for belongs_to associations where we control whether the
      # association is required via the deprecated `required` option instead.
      #
      # Since Rails 5, belongs_to associations are required by default and this
      # can be controlled through the use of `optional: true`.
      #
      # From the release notes:
      #
      #     belongs_to will now trigger a validation error by default if the
      #     association is not present. You can turn this off on a
      #     per-association basis with optional: true. Also deprecate required
      #     option in favor of optional for belongs_to. (Pull Request)
      #
      # In the case that the developer is doing `required: false`, we
      # definitely want to autocorrect to `optional: true`.
      #
      # However, without knowing whether they've set overridden the default
      # value of `config.active_record.belongs_to_required_by_default`, we
      # can't say whether it's safe to remove `required: true` or whether we
      # should replace it with `optional: false` (or, similarly, remove a
      # superfluous `optional: false`). Therefore, in the cases we're using
      # `required: true`, we'll simply invert it to `optional: false` and the
      # user can remove depending on their defaults.
      #
      # @example
      #   # bad
      #   class Post < ApplicationRecord
      #     belongs_to :blog, required: false
      #   end
      #
      #   # good
      #   class Post < ApplicationRecord
      #     belongs_to :blog, optional: true
      #   end
      #
      #   # bad
      #   class Post < ApplicationRecord
      #     belongs_to :blog, required: true
      #   end
      #
      #   # good
      #   class Post < ApplicationRecord
      #     belongs_to :blog, optional: false
      #   end
      #
      # @see https://guides.rubyonrails.org/5_0_release_notes.html
      # @see https://github.com/rails/rails/pull/18937
      class BelongsTo < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        SUPERFLOUS_REQUIRE_FALSE_MSG =
          'You specified `required: false`, in Rails > 5.0 the required ' \
          'option is deprecated and you want to use `optional: true`.'.freeze

        SUPERFLOUS_REQUIRE_TRUE_MSG =
          'You specified `required: true`, in Rails > 5.0 the required ' \
          'option is deprecated and you want to use `optional: false`. ' \
          'In most configurations, this is the default and you can omit ' \
          'this option altogether'.freeze

        def_node_matcher :match_belongs_to_with_options, <<-PATTERN
          (send $_ :belongs_to _ (hash $...))
        PATTERN

        def_node_matcher :match_required_false?, <<-PATTERN
          (pair (sym :required) false)
        PATTERN

        def_node_matcher :match_required_true?, <<-PATTERN
          (pair (sym :required) true)
        PATTERN

        def on_send(node)
          opt = extract_required_option(node)
          return unless opt
          return unless match_required_true?(opt) || match_required_false?(opt)

          message =
            if match_required_true?(opt)
              SUPERFLOUS_REQUIRE_TRUE_MSG
            elsif match_required_false?(opt)
              SUPERFLOUS_REQUIRE_FALSE_MSG
            end

          add_offense(node, message: message, location: :selector)
        end

        def autocorrect(node)
          opt = extract_required_option(node)
          return unless opt

          lambda do |corrector|
            if match_required_true?(opt)
              corrector.replace(opt.loc.expression, 'optional: false')
            elsif match_required_false?(opt)
              corrector.replace(opt.loc.expression, 'optional: true')
            end
          end
        end

        def extract_required_option(node)
          _, opts = match_belongs_to_with_options(node)
          return unless opts

          opts.find do |opt|
            match_required_true?(opt) ||
              match_required_false?(opt)
          end
        end
      end
    end
  end
end
