# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # In Ruby 2.3 or later, use unary plus operator to unfreeze a string
      # literal instead of `String#dup` and `String.new`.
      # Unary plus operator is faster than `String#dup`.
      #
      # Note: `String.new` (without operator) is not exactly the same as `+''`.
      # These differ in encoding. `String.new.encoding` is always `ASCII-8BIT`.
      # However, `(+'').encoding` is the same as script encoding(e.g. `UTF-8`).
      # So, if you expect `ASCII-8BIT` encoding, disable this cop.
      #
      # @example
      #   # bad
      #   ''.dup
      #   "something".dup
      #   String.new
      #   String.new('')
      #   String.new('something')
      #
      #   # good
      #   +'something'
      #   +''
      class UnfreezeString < Cop
        extend TargetRubyVersion

        minimum_target_ruby_version 2.3

        MSG = 'Use unary plus to get an unfrozen string literal.'.freeze

        def_node_matcher :dup_string?, <<-PATTERN
          (send {str dstr} :dup)
        PATTERN

        def_node_matcher :string_new?, <<-PATTERN
          {
            (send (const nil? :String) :new {str dstr})
            (send (const nil? :String) :new)
          }
        PATTERN

        def on_send(node)
          add_offense(node) if dup_string?(node) || string_new?(node)
        end
      end
    end
  end
end
