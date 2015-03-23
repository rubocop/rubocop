# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `shuffle.first` and
      # change them to use `sample` instead.
      #
      # @example
      #   # bad
      #   [1, 2, 3].shuffle.first
      #   [1, 2, 3].shuffle.last
      #   [1, 2, 3].shuffle[0]
      #
      #   # good
      #   [1, 2, 3].sample
      class Sample < Cop
        MSG = 'Use `sample` instead of `shuffle.%s`.'
        MSG_SELECTOR = 'Use `sample` instead of `shuffle[%s]`.'
        ARRAY_SELECTORS = [:first, :last, :[]]

        def on_send(node)
          receiver, second_method, selector = *node
          return unless ARRAY_SELECTORS.include?(second_method)
          return if receiver.nil?
          _array, first_method = *receiver
          return unless first_method == :shuffle

          begin_of_offense = receiver.loc.selector.begin_pos
          end_of_offense = node.loc.selector.end_pos
          range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                            begin_of_offense,
                                            end_of_offense)

          message = if second_method == :[]
                      format(MSG_SELECTOR, selector.loc.expression.source)
                    else
                      format(MSG, second_method)
                    end

          add_offense(node, range, message)
        end

        def autocorrect(node)
          receiver, = *node
          location_of_shuffle = receiver.loc.selector.begin_pos
          range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                            location_of_shuffle,
                                            node.loc.selector.end_pos)

          @corrections << lambda do |corrector|
            corrector.replace(range, 'sample')
          end
        end
      end
    end
  end
end
