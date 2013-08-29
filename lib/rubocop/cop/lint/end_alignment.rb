# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly.
      #
      # For keywords (if, def, etc.) the end is aligned with the start
      # of the keyword.
      #
      # @example
      #
      #   variable = if true
      #              end
      class EndAlignment < Cop
        MSG = 'end at %d, %d is not aligned with %s at %d, %d'

        def on_def(node)
          check(node)
        end

        def on_defs(node)
          check(node)
        end

        def on_class(node)
          check(node)
        end

        def on_module(node)
          check(node)
        end

        def on_if(node)
          check(node) if node.loc.respond_to?(:end)
        end

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        private

        def check(node)
          # discard modifier forms of if/while/until
          return unless node.loc.end

          kw_loc = node.loc.keyword
          end_loc = node.loc.end

          if kw_loc.line != end_loc.line && kw_loc.column != end_loc.column
            warning(nil,
                    end_loc,
                    sprintf(MSG, end_loc.line, end_loc.column,
                            kw_loc.source, kw_loc.line, kw_loc.column))
          end
        end
      end
    end
  end
end
