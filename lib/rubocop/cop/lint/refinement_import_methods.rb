# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks if `include` or `prepend` is called in `refine` block.
      # These methods are deprecated and should be replaced with `Refinement#import_methods`.
      #
      # It emulates deprecation warnings in Ruby 3.1. Functionality has been removed in Ruby 3.2.
      #
      # @safety
      #   This cop's autocorrection is unsafe because `include M` will affect the included class
      #   if any changes are made to module `M`.
      #   On the other hand, `import_methods M` uses a snapshot of method definitions,
      #   thus it will not be affected if module `M` changes.
      #
      # @example
      #
      #   # bad
      #   refine Foo do
      #     include Bar
      #   end
      #
      #   # bad
      #   refine Foo do
      #     prepend Bar
      #   end
      #
      #   # good
      #   refine Foo do
      #     import_methods Bar
      #   end
      #
      class RefinementImportMethods < Base
        extend AutoCorrector
        extend TargetRubyVersion

        MSG = 'Use `import_methods` instead of `%<current>s` because it is deprecated in Ruby 3.1.'
        MSG_REMOVED = 'Use `import_methods` instead of `%<current>s` ' \
                      'because it was removed in Ruby 3.2.'
        RESTRICT_ON_SEND = %i[include prepend].freeze

        minimum_target_ruby_version 3.1

        def on_send(node)
          return if node.receiver
          return unless (parent = node.parent)
          return unless parent.block_type? && parent.method?(:refine)

          template = target_ruby_version >= 3.2 ? MSG_REMOVED : MSG
          message = format(template, current: node.method_name)
          add_offense(node.loc.selector, message: message) do |corrector|
            corrector.replace(node.loc.selector, 'import_methods')
          end
        end
      end
    end
  end
end
