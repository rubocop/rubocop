# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects unused arguments.
    class UnusedArgCorrector
      extend Util

      class << self
        attr_reader :processed_source

        def correct(processed_source, node)
          return if %i[kwarg kwoptarg].include?(node.type)

          @processed_source = processed_source

          if node.blockarg_type?
            lambda do |corrector|
              range = range_with_surrounding_space(range: node.source_range,
                                                   side: :left)
              range = range_with_surrounding_comma(range, :left)
              corrector.remove(range)
            end
          else
            ->(corrector) { corrector.insert_before(node.loc.name, '_') }
          end
        end
      end
    end
  end
end
