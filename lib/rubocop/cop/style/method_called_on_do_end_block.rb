# encoding: utf-8

module Rubocop
  module Cop
    module Style

      # This cop checks for a method being called on a block which uses do/end
      #
      # @example
      #
      # [1, 2, 3, 4].map do |i|
      #   i + 2 if i.even?
      # end.compact
      class MethodCalledOnDoEndBlock < Cop
        MSG = 'Avoid method calls on blocks that use do/end'

        def on_send(node)
          receiver, _method_name, *_args = *node
          if receiver && receiver.type == :block && !ignored_node?(receiver)
            # we have a block
            check(receiver, node, MSG)
          end
        end

        # If there is an offence, adds the offence and returns true.
        def check(receiver, send_node, msg)
          # check that we have do ... end and not braces
          if receiver.loc.begin.source == 'do' &&
             receiver.loc.end.source == 'end'
            end_loc = receiver.loc.end
            range = Parser::Source::Range.new(end_loc.source_buffer,
                                              end_loc.begin_pos,
                                              send_node.loc.expression.end_pos)
            convention(nil, range, msg)
          end
        end
      end
    end
  end
end
