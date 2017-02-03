# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop checks for .times.map calls.
      # In most cases such calls can be replaced
      # with an explicit array creation.
      #
      # @example
      #
      #   @bad
      #   9.times.map do |i|
      #     i.to_s
      #   end
      #
      #   @good
      #   Array.new(9) do |i|
      #     i.to_s
      #   end
      class TimesMap < Cop
        MSG = 'Use `Array.new` with a block instead of `.times.%s`.'.freeze

        def on_send(node)
          check(node)
        end

        def on_block(node)
          check(node)
        end

        private

        def check(node)
          times_map_call(node) do |map_or_collect|
            add_offense(node, :expression, format(MSG, map_or_collect))
          end
        end

        def_node_matcher :times_map_call, <<-END
          {(block (send (send !nil :times) ${:map :collect}) ...)
           (send (send !nil :times) ${:map :collect} (block_pass ...))}
        END

        def autocorrect(node)
          send_node = node.send_type? ? node : node.each_descendant(:send).first

          count, = *send_node.receiver

          replacement =
            "Array.new(#{count.source}" \
            "#{send_node.arguments.map { |arg| ", #{arg.source}" }.join})"

          lambda do |corrector|
            corrector.replace(send_node.loc.expression, replacement)
          end
        end
      end
    end
  end
end
