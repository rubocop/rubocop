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
        MSG = '$%<backref>s is out of range (%<count>s regexp capture %<group>s detected).'

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

        def after_send(node)
          @valid_ref = nil

          if regexp_first_argument?(node)
            check_regexp(node.first_argument)
          elsif regexp_receiver?(node)
            check_regexp(node.receiver)
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
          return if @valid_ref.nil? || backref <= @valid_ref

          message = format(
            MSG,
            backref: backref,
            count: @valid_ref.zero? ? 'no' : @valid_ref,
            group: @valid_ref == 1 ? 'group' : 'groups'
          )

          add_offense(node, message: message)
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

        def regexp_first_argument?(send_node)
          send_node.first_argument&.regexp_type? \
            && REGEXP_ARGUMENT_METHODS.include?(send_node.method_name)
        end

        def regexp_receiver?(send_node)
          send_node.receiver&.regexp_type?
        end

        def nth_ref_receiver?(send_node)
          send_node.receiver&.nth_ref_type?
        end
      end
    end
  end
end
