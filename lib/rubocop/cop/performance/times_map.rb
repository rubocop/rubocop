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
        MESSAGE = 'Use `Array.new(%<count>s)` with a block ' \
                  'instead of `.times.%<map_or_collect>s`'.freeze
        MESSAGE_ONLY_IF = 'only if `%<count>s` is always 0 or more'.freeze

        def on_send(node)
          check(node)
        end

        def on_block(node)
          check(node)
        end

        private

        def check(node)
          times_map_call(node) do |map_or_collect, count|
            add_offense(node, :expression, message(map_or_collect, count))
          end
        end

        def message(map_or_collect, count)
          template = if count.literal?
                       MESSAGE + '.'
                     else
                       "#{MESSAGE} #{MESSAGE_ONLY_IF}."
                     end
          format(template,
                 count: count.source,
                 map_or_collect: map_or_collect.method_name)
        end

        def_node_matcher :times_map_call, <<-PATTERN
          {(block $(send (send $!nil :times) {:map :collect}) ...)
           $(send (send $!nil :times) {:map :collect} (block_pass ...))}
        PATTERN

        def autocorrect(node)
          map_or_collect, count = times_map_call(node)

          replacement =
            "Array.new(#{count.source}" \
            "#{map_or_collect.arguments.map { |arg| ", #{arg.source}" }.join})"

          lambda do |corrector|
            corrector.replace(map_or_collect.loc.expression, replacement)
          end
        end
      end
    end
  end
end
