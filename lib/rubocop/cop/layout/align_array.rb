# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Here we check if the elements of a multi-line array literal are
      # aligned.
      #
      # @example
      #   # bad
      #   a = [1, 2, 3
      #     4, 5, 6]
      #   array = ['run',
      #        'forrest',
      #        'run']
      #
      #   # good
      #   a = [1, 2, 3
      #        4, 5, 6]
      #   a = ['run',
      #        'forrest',
      #        'run']
      class AlignArray < Cop
        include AutocorrectAlignment

        MSG = 'Align the elements of an array literal if they span more ' \
              'than one line.'.freeze

        def on_array(node)
          check_alignment(node.children)
        end
      end
    end
  end
end
