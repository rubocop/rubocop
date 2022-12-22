# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for accessing the first element of `String#unpack`
      # which can be replaced with the shorter method `unpack1`.
      #
      # @example
      #
      #   # bad
      #   'foo'.unpack('h*').first
      #   'foo'.unpack('h*')[0]
      #   'foo'.unpack('h*').slice(0)
      #   'foo'.unpack('h*').at(0)
      #
      #   # good
      #   'foo'.unpack1('h*')
      #
      class UnpackFirst < Base
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.4

        MSG = 'Use `%<receiver>s.unpack1(%<format>s)` instead of ' \
              '`%<receiver>s.unpack(%<format>s)%<method>s`.'
        RESTRICT_ON_SEND = %i[first [] slice at].freeze

        # @!method unpack_and_first_element?(node)
        def_node_matcher :unpack_and_first_element?, <<~PATTERN
          {
            (send $(send (...) :unpack $(...)) :first)
            (send $(send (...) :unpack $(...)) {:[] :slice :at} (int 0))
          }
        PATTERN

        def on_send(node)
          unpack_and_first_element?(node) do |unpack_call, unpack_arg|
            range = first_element_range(node, unpack_call)
            message = format(MSG,
                             receiver: unpack_call.receiver.source,
                             format: unpack_arg.source,
                             method: range.source)
            add_offense(node, message: message) do |corrector|
              corrector.remove(first_element_range(node, unpack_call))
              corrector.replace(unpack_call.loc.selector, 'unpack1')
            end
          end
        end

        private

        def first_element_range(node, unpack_call)
          Parser::Source::Range.new(node.source_range.source_buffer,
                                    unpack_call.source_range.end_pos,
                                    node.source_range.end_pos)
        end
      end
    end
  end
end
