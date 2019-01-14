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
      # However, without knowing whether they've set overriden the default
      # value of `config.active_record.belongs_to_required_by_default`, we
      # can't say whether it's safe to remove `required: true` or replace it
      # with `optional: false` (or, similarly, remove a superfluous `optional:
      # false`). Therefore, in the cases we're using `required: true`, we'll
      # highlight that `required` is deprecated but otherwise do nothing.
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
      # @see https://guides.rubyonrails.org/5_0_release_notes.html
      # @see https://github.com/rails/rails/pull/18937
      class BelongsTo < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 5.0

        DEPRECATED_REQUIRE =
          'The use of `required` on belongs_to associations was deprecated ' \
          'in Rails 5. Please use the `optional` flag instead'.freeze

        SUPERFLOUS_REQUIRE_MSG =
          'You specified `required: false`, in Rails > 5.0 the requires ' \
          'option is deprecated and you want to use `optional: true`.'.freeze

        def_node_matcher :match_belongs_to_with_options, <<-PATTERN
          (send $_ :belongs_to _ (hash $...))
        PATTERN

        def_node_matcher :match_requires_false?, <<-PATTERN
          (pair (sym :required) false)
        PATTERN

        def_node_matcher :match_requires_any?, <<-PATTERN
          (pair (sym :required) $_)
        PATTERN

        def on_send(node)
          _, opts = match_belongs_to_with_options(node)
          if opts && opts.any? { |opt| match_requires_false?(opt) }
            add_offense(
              node,
              message: SUPERFLOUS_REQUIRE_MSG,
              location: :selector
            )
          elsif opts && opts.any? { |opt| match_requires_any?(opt) }
            add_offense(
              node,
              message: DEPRECATED_REQUIRE,
              location: :selector
            )
          end
        end

        def autocorrect(node)
          _, opts = match_belongs_to_with_options(node)
          return nil if opts && opts.none? { |opt| match_requires_false?(opt) }

          lambda do |corrector|
            requires_expression =
              node.children[3].children.find { |c| match_requires_false?(c) }

            corrector.replace(
              requires_expression.loc.expression,
              'optional: true'
            )
          end
        end
      end
    end
  end
end
