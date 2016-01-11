# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of
      #
      # @example
      #   # bad
      #   [1, 2, 3, 4].map { |e| [e, e] }.flatten(1)
      #   [1, 2, 3, 4].collect { |e| [e, e] }.flatten(1)
      #
      #   # good
      #   [1, 2, 3, 4].flat_map { |e| [e, e] }
      #   [1, 2, 3, 4].map { |e| [e, e] }.flatten
      #   [1, 2, 3, 4].collect { |e| [e, e] }.flatten
      class FlatMap < Cop
        MSG = 'Use `flat_map` instead of `%s...%s`.'.freeze
        FLATTEN_MULTIPLE_LEVELS = ' Beware, `flat_map` only flattens 1 level ' \
                                  'and `flatten` can be used to flatten ' \
                                  'multiple levels.'.freeze
        FLATTEN = [:flatten, :flatten!].freeze

        def on_send(node)
          left, second_method, flatten_param = *node
          return unless FLATTEN.include?(second_method)
          flatten_level, = *flatten_param
          expression, = *left
          _array, first_method = *expression
          return unless first_method == :map || first_method == :collect

          message = MSG
          if cop_config['EnabledForFlattenWithoutParams'] && flatten_level.nil?
            message = MSG + FLATTEN_MULTIPLE_LEVELS
          elsif flatten_level != 1
            return
          end

          range = Parser::Source::Range.new(node.source_range.source_buffer,
                                            expression.loc.selector.begin_pos,
                                            node.loc.selector.end_pos)

          add_offense(node, range, format(message, first_method, second_method))
        end

        def autocorrect(node)
          receiver, _flatten, flatten_param = *node
          flatten_level, = *flatten_param
          return if flatten_level.nil?

          array, = *receiver

          lambda do |corrector|
            range = Parser::Source::Range.new(node.source_range.source_buffer,
                                              node.loc.dot.begin_pos,
                                              node.source_range.end_pos)

            corrector.remove(range)
            corrector.replace(array.loc.selector, 'flat_map')
          end
        end
      end
    end
  end
end
