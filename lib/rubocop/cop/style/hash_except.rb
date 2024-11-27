# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for usages of `Hash#reject`, `Hash#select`, and `Hash#filter` methods
      # that can be replaced with `Hash#except` method.
      #
      # This cop should only be enabled on Ruby version 3.0 or higher.
      # (`Hash#except` was added in Ruby 3.0.)
      #
      # For safe detection, it is limited to commonly used string and symbol comparisons
      # when used `==`.
      # And do not check `Hash#delete_if` and `Hash#keep_if` to change receiver object.
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the receiver
      #   is a `Hash` or responds to the replacement method.
      #
      # @example
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k == :bar }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| k != :bar }
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k.eql?(:bar) }
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| %i[bar].include?(k) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| !%i[bar].include?(k) }
      #   {foo: 1, bar: 2, baz: 3}.filter {|k, v| !%i[bar].include?(k) }
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| !%i[bar].exclude?(k) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| %i[bar].exclude?(k) }
      #
      #   # bad
      #   {foo: 1, bar: 2, baz: 3}.reject {|k, v| k.in?(%i[bar]) }
      #   {foo: 1, bar: 2, baz: 3}.select {|k, v| !k.in?(%i[bar]) }
      #
      #   # good
      #   {foo: 1, bar: 2, baz: 3}.except(:bar)
      #
      class HashExcept < Base
        include HashSliceExcept
        extend TargetRubyVersion
        extend AutoCorrector

        minimum_target_ruby_version 3.0

        MSG = 'Use `%<prefer>s` instead.'

        def on_send(node)
          offense_range, key_source = extract_offense(node)

          return unless offense_range
          return unless semantically_except_method?(node)

          preferred_method = "except(#{key_source})"
          add_offense(offense_range, message: format(MSG, prefer: preferred_method)) do |corrector|
            corrector.replace(offense_range, preferred_method)
          end
        end
        alias on_csend on_send
      end
    end
  end
end
