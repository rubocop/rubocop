# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for uses a file requiring itself with `require_relative`.
      #
      # @example
      #
      #   # bad
      #
      #   # foo.rb
      #   require_relative 'foo'
      #   require_relative 'bar'
      #
      #   # good
      #
      #   # foo.rb
      #   require_relative 'bar'
      #
      class RequireRelativeSelfPath < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove the `require_relative` that requires itself.'
        RESTRICT_ON_SEND = %i[require_relative].freeze

        def on_send(node)
          return unless (required_feature = node.first_argument)
          return unless remove_ext(processed_source.file_path) == remove_ext(required_feature.value)

          add_offense(node) do |corrector|
            corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
          end
        end

        private

        def remove_ext(file_path)
          File.basename(file_path, File.extname(file_path))
        end
      end
    end
  end
end
