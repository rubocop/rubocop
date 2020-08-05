# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cops looks for references of Regexp captures that are out of range
      # and thus always returns nil.
      #
      # @example
      #
      #   /(foo)bar/ =~ 'foobar'
      #
      #   # bad - always returns nil
      #
      #   puts $2 # => nil
      #
      #   # good
      #
      #   puts $1 # => foo
      #
      class OutOfRangeRegexpRef < Base
        MSG = 'Do not use out of range reference for the Regexp.'

        def on_new_investigation
          @valid_ref = 0
        end

        def on_regexp(node)
          @valid_ref = nil
          return if contain_non_literal?(node)

          tree = Regexp::Parser.parse(node.content)
          @valid_ref = regexp_captures(tree)
        end

        def on_nth_ref(node)
          backref, = *node
          return if @valid_ref.nil?

          add_offense(node) if backref > @valid_ref
        end

        private

        def contain_non_literal?(node)
          node.children.size != 2 || !node.children.first.str_type?
        end

        def regexp_captures(tree)
          named_capture = numbered_capture = 0
          tree.each_expression do |e|
            if e.type?(:group)
              e.respond_to?(:name) ? named_capture += 1 : numbered_capture += 1
            end
          end
          named_capture.positive? ? named_capture : numbered_capture
        end
      end
    end
  end
end
