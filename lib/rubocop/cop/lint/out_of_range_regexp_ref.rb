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

        REGEXP_RECEIVER_METHODS = %i[=~ === match].to_set.freeze
        REGEXP_ARGUMENT_METHODS = %i[=~ match grep gsub gsub! sub sub! [] slice slice! index rindex
                                     scan partition rpartition start_with? end_with?].to_set.freeze
        REGEXP_CAPTURE_METHODS = (REGEXP_RECEIVER_METHODS + REGEXP_ARGUMENT_METHODS).freeze
        RESTRICT_ON_SEND = REGEXP_CAPTURE_METHODS

        def on_new_investigation
          @valid_ref = 0
        end

        def on_match_with_lvasgn(node)
          check_regexp(node.children.first)
        end

        def on_send(node)
          @valid_ref = nil

          if node.receiver&.regexp_type?
            check_regexp(node.receiver)
          elsif node.first_argument&.regexp_type? \
            && REGEXP_ARGUMENT_METHODS.include?(node.method_name)
            check_regexp(node.first_argument)
          end
        end

        def on_when(node)
          regexp_conditions = node.conditions.select(&:regexp_type?)

          @valid_ref = regexp_conditions.map do |condition|
            check_regexp(condition)
          end.compact.max
        end

        def on_nth_ref(node)
          backref, = *node
          return if @valid_ref.nil?

          add_offense(node) if backref > @valid_ref
        end

        private

        def check_regexp(node)
          return if node.interpolation?

          named_capture = node.each_capture(named: true).count
          @valid_ref = if named_capture.positive?
                         named_capture
                       else
                         node.each_capture(named: false).count
                       end
        end
      end
    end
  end
end
