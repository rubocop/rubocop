# encoding: UTF-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `shuffle.first`, `shuffle.last`
      # and `shuffle[]` and change them to use `sample` instead.
      #
      # @example
      #   # bad
      #   [1, 2, 3].shuffle.first
      #   [1, 2, 3].shuffle.first(2)
      #   [1, 2, 3].shuffle.last
      #   [1, 2, 3].shuffle[2]
      #   [1, 2, 3].shuffle[0, 2]    # sample(2) will do the same
      #   [1, 2, 3].shuffle[0..2]    # sample(3) will do the same
      #   [1, 2, 3].shuffle(random: Random.new).first
      #
      #   # good
      #   [1, 2, 3].shuffle
      #   [1, 2, 3].sample
      #   [1, 2, 3].sample(3)
      #   [1, 2, 3].shuffle[1, 3]    # sample(3) might return a longer Array
      #   [1, 2, 3].shuffle[1..3]    # sample(3) might return a longer Array
      #   [1, 2, 3].shuffle[foo, bar]
      #   [1, 2, 3].shuffle(random: Random.new)
      class Sample < Cop
        MSG = 'Use `%<correct>s` instead of `%<incorrect>s`.'.freeze

        def on_send(node)
          analyzer = ShuffleAnalyzer.new(node)
          return unless analyzer.offensive?
          add_offense(node, analyzer.source_range, analyzer.message)
        end

        def autocorrect(node)
          ShuffleAnalyzer.new(node).autocorrect
        end

        # An internal class for representing a shuffle + method node analyzer.
        class ShuffleAnalyzer
          def initialize(shuffle_node)
            @shuffle_node = shuffle_node
            @method_node  = shuffle_node.parent
          end

          def autocorrect
            ->(corrector) { corrector.replace(source_range, correct) }
          end

          def message
            format(MSG, correct: correct, incorrect: source_range.source)
          end

          def offensive?
            shuffle_node.to_a[1] == :shuffle && corrigible?
          end

          def source_range
            Parser::Source::Range.new(shuffle_node.source_range.source_buffer,
                                      shuffle_node.loc.selector.begin_pos,
                                      method_node.source_range.end_pos)
          end

          private

          attr_reader :method_node, :shuffle_node

          def correct
            args = [sample_arg, shuffle_arg].compact.join(', ')
            args.empty? ? 'sample' : "sample(#{args})"
          end

          def corrigible?
            case method
            when :first, :last then true
            when :[]           then sample_size != :unknown
            else false
            end
          end

          def method
            method_node.to_a[1]
          end

          def method_arg
            _, _, arg = *method_node
            arg.source if arg
          end

          def range_size(range_node)
            vals = *range_node
            return :unknown unless vals.all?(&:int_type?)
            low, high = *vals.map(&:to_a).map(&:first)
            return :unknown unless low.zero? && high >= 0
            case range_node.type
            when :erange then high - low
            when :irange then high - low + 1
            end
          end

          def sample_arg
            case method
            when :first, :last then method_arg
            when :[]           then sample_size
            end
          end

          def sample_size
            _, _, *args = *method_node
            case args.size
            when 1 then sample_size_for_one_arg(args.first)
            when 2 then sample_size_for_two_args(*args)
            end
          end

          def sample_size_for_one_arg(arg)
            case arg.type
            when :erange, :irange then range_size(arg)
            when :int             then arg.to_a.first.zero? ? nil : :unknown
            else :unknown
            end
          end

          def sample_size_for_two_args(first, second)
            return :unknown unless first.int_type? && first.to_a.first.zero?
            second.int_type? ? second.to_a.first : :unknown
          end

          def shuffle_arg
            _, _, arg = *shuffle_node
            arg.source if arg
          end
        end
      end
    end
  end
end
