# frozen_string_literal: true

module RuboCop
  module Cop
    # This class does empty line auto-correction
    class EmptyLineCorrector
      class << self
        def correct(node)
          offense_style, range = node
          lambda do |corrector|
            case offense_style
            when :no_empty_lines
              corrector.remove(range)
            when :empty_lines
              corrector.insert_before(range, "\n")
            end
          end
        end

        def insert_before(node)
          ->(corrector) { corrector.insert_before(node, "\n") }
        end
      end
    end
  end
end
