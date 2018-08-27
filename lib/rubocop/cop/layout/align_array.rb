# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Here we check if the elements of a multi-line array literal are
      # aligned.
      #
      # @example
      #   # bad
      #   a = [1, 2, 3,
      #     4, 5, 6]
      #   array = ['run',
      #        'forrest',
      #        'run']
      #
      #   # good
      #   a = [1, 2, 3,
      #        4, 5, 6]
      #   a = ['run',
      #        'forrest',
      #        'run']
      class AlignArray < Cop
        include Alignment

        MSG = 'Ensure lines containing elements on an array literal ' \
              'have the same indentation.'.freeze

        def on_array(node)
          check_alignment(node.children)
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, column_delta)
        end
      end
    end
  end
end
