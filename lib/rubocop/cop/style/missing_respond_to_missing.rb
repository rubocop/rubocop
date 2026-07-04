# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for the presence of `method_missing` without also
      # defining `respond_to_missing?`.
      #
      # Not defining `respond_to_missing?` will cause metaprogramming
      # methods like `respond_to?` to behave unexpectedly:
      #
      # [source,ruby]
      # ----
      # class StringDelegator
      #   def initialize(string)
      #     @string = string
      #   end
      #
      #   def method_missing(name, *args)
      #     @string.send(name, *args)
      #   end
      # end
      #
      # delegator = StringDelegator.new("foo")
      # # Claims to not respond to `upcase`.
      # delegator.respond_to?(:upcase) # => false
      # # But you can call it.
      # delegator.upcase # => FOO
      # ----
      #
      # @example
      #   # bad
      #   def method_missing(name, *args)
      #     if @delegate.respond_to?(name)
      #       @delegate.send(name, *args)
      #     else
      #       super
      #     end
      #   end
      #
      #   # good
      #   def respond_to_missing?(name, include_private)
      #     @delegate.respond_to?(name) || super
      #   end
      #
      #   def method_missing(name, *args)
      #     if @delegate.respond_to?(name)
      #       @delegate.send(name, *args)
      #     else
      #       super
      #     end
      #   end
      #
      class MissingRespondToMissing < Base
        MSG = 'When using `method_missing`, define `respond_to_missing?`.'

        def on_def(node)
          return unless node.method?(:method_missing)
          return if implements_respond_to_missing?(node)

          add_offense(node)
        end
        alias on_defs on_def

        private

        def implements_respond_to_missing?(node)
          scope = enclosing_scope(node)
          search_root = scope || node.parent
          return false unless search_root

          search_root.each_descendant(node.type).any? do |descendant|
            descendant.method?(:respond_to_missing?) && enclosing_scope(descendant).equal?(scope)
          end
        end

        # The class/module/`class << self` body that lexically contains `node`,
        # or `nil` when `node` is defined at the top level.
        def enclosing_scope(node)
          node.each_ancestor(:class, :module, :sclass).first
        end
      end
    end
  end
end
