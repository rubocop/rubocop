# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of `String#split` with empty string or regexp literal argument.
      #
      # This cop is marked as unsafe. But probably it's quite unlikely that some other class would
      # define a `split` method that takes exactly the same arguments.
      #
      # @example
      #   # bad
      #   string.split(//)
      #   string.split('')
      #
      #   # good
      #   string.chars
      #
      class StringChars < Base
        extend AutoCorrector

        MSG = 'Use `chars` instead of `%<current>s`.'
        RESTRICT_ON_SEND = %i[split].freeze
        BAD_ARGUMENTS = %w[// '' ""].freeze

        def on_send(node)
          return unless node.arguments.one? && BAD_ARGUMENTS.include?(node.first_argument.source)

          range = node.loc.selector.begin.join(node.loc.end)

          add_offense(range, message: format(MSG, current: range.source)) do |corrector|
            corrector.replace(range, 'chars')
          end
        end
      end
    end
  end
end
