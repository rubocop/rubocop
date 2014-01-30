# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks redundant empty lines around the bodies of classes,
      # modules & methods.
      #
      # @example
      #
      #   class Test
      #
      #      def something
      #        ...
      #      end
      #
      #   end
      #
      #   def something(arg)
      #
      #     ...
      #   end
      #
      class EmptyLinesAroundBody < Cop
        include CheckMethods

        MSG_BEG = 'Extra empty line detected at body beginning.'
        MSG_END = 'Extra empty line detected at body end.'

        def on_class(node)
          check(node)
        end

        def on_module(node)
          check(node)
        end

        def on_sclass(node)
          check(node)
        end

        def autocorrect(range)
          @corrections << ->(corrector) { corrector.remove(range) }
        end

        private

        def check(node, *_)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          check_source(start_line, end_line)
        end

        def check_source(start_line, end_line)
          check_line(start_line, MSG_BEG)
          check_line(end_line - 2, MSG_END) unless end_line - 2 == start_line
        end

        def check_line(line, msg)
          if processed_source.lines[line].empty?
            range = source_range(processed_source.buffer,
                                 processed_source[0...line],
                                 0,
                                 1)
            add_offence(range, range, msg)
          end
        end
      end
    end
  end
end
