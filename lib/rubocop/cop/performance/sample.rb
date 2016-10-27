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

        def_node_matcher :sample_candidate?, <<-PATTERN
          (send $(send _ :shuffle $...) ${:first :last :[]} $...)
        PATTERN

        def on_send(node)
          sample_candidate?(node) do |shuffle, shuffle_arg, method, method_args|
            return unless offensive?(method, method_args)

            range = source_range(shuffle, node)
            message = message(shuffle_arg, method, method_args, range)
            add_offense(node, range, message)
          end
        end

        def autocorrect(node)
          shuffle_node, shuffle_arg, method, method_args =
            sample_candidate?(node)

          lambda do |corrector|
            corrector.replace(source_range(shuffle_node, node),
                              correction(shuffle_arg, method, method_args))
          end
        end

        private

        def offensive?(method, method_args)
          case method
          when :first, :last
            true
          when :[]
            sample_size(method_args) != :unknown
          else
            false
          end
        end

        def sample_size(method_args)
          case method_args.size
          when 1
            sample_size_for_one_arg(method_args.first)
          when 2
            sample_size_for_two_args(*method_args)
          end
        end

        def sample_size_for_one_arg(arg)
          case arg.type
          when :erange, :irange
            range_size(arg)
          when :int
            arg.to_a.first.zero? ? nil : :unknown
          else
            :unknown
          end
        end

        def sample_size_for_two_args(first, second)
          return :unknown unless first.int_type? && first.to_a.first.zero?
          second.int_type? ? second.to_a.first : :unknown
        end

        def range_size(range_node)
          vals = range_node.to_a
          return :unknown unless vals.all?(&:int_type?)
          low, high = vals.map { |val| val.children[0] }
          return :unknown unless low.zero? && high >= 0

          case range_node.type
          when :erange
            (low...high).size
          when :irange
            (low..high).size
          end
        end

        def source_range(shuffle_node, node)
          Parser::Source::Range.new(shuffle_node.source_range.source_buffer,
                                    shuffle_node.loc.selector.begin_pos,
                                    node.source_range.end_pos)
        end

        def message(shuffle_arg, method, method_args, range)
          format(MSG,
                 correct: correction(shuffle_arg, method, method_args),
                 incorrect: range.source)
        end

        def correction(shuffle_arg, method, method_args)
          shuffle_arg = extract_source(shuffle_arg)
          sample_arg = sample_arg(method, method_args)
          args = [sample_arg, shuffle_arg].compact.join(', ')
          args.empty? ? 'sample' : "sample(#{args})"
        end

        def sample_arg(method, method_args)
          case method
          when :first, :last
            extract_source(method_args)
          when :[]
            sample_size(method_args)
          end
        end

        def extract_source(args)
          args.empty? ? nil : args.first.source
        end
      end
    end
  end
end
