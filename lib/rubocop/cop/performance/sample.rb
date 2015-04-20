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
      #   [1, 2, 3].shuffle[0, 3]
      #   [1, 2, 3].shuffle(random: Random.new(1))
      #
      #   # good
      #   [1, 2, 3].sample
      #   [1, 2, 3].sample(3)
      #   [1, 2, 3].sample(random: Random.new(1))
      class Sample < Cop
        MSG = 'Use `sample` instead of `shuffle%s`.'
        RANGE_TYPES = [:irange, :erange]

        def on_send(node)
          _receiver, method, params, = *node
          return unless method == :shuffle
          _receiver, _method, params, = *node.parent if params.nil?

          message = if params && params.lvar_type?
                      format(MSG, shuffle_params(node))
                    elsif node.parent
                      _params, selector = *node.parent
                      if selector == :[]
                        format(MSG, node.parent.loc.selector.source)
                      else
                        format(MSG, ".#{node.parent.loc.selector.source}")
                      end
                    else
                      format(MSG, shuffle_params(node))
                    end

          add_offense(node, range_of_shuffle(node), message)
        end

        def autocorrect(node)
          _receiver, _method, params, selector = *node
          _receiver, _method, params, selector = *node.parent if params.nil?

          return if params && RANGE_TYPES.include?(params.type)

          range = if params && (params.hash_type? || params.lvar_type?)
                    range_of_shuffle(node)
                  else
                    Parser::Source::Range.new(node.loc.expression.source_buffer,
                                              node.loc.selector.begin_pos,
                                              node.parent.loc.selector.end_pos)
                  end

          @corrections << lambda do |corrector|
            corrector.replace(range, 'sample')
            return if selector.nil?
            corrector.insert_after(range, "(#{selector.loc.expression.source})")
          end
        end

        private

        def range_of_shuffle(node)
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    node.loc.selector.begin_pos,
                                    node.loc.selector.end_pos)
        end

        def shuffle_params(node)
          params = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                             node.loc.selector.end_pos,
                                             node.loc.expression.end_pos)
          params.source
        end
      end
    end
  end
end
