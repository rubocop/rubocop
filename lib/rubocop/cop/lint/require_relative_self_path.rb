# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for a file requiring itself with `require_relative`.
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
          return unless required_feature.respond_to?(:value)
          return unless same_file?(processed_source.file_path, required_feature.value)

          add_offense(node) do |corrector|
            corrector.remove(range_by_whole_lines(node.source_range, include_final_newline: true))
          end
        end

        private

        def same_file?(file_path, required_feature)
          return false unless File.extname(file_path) == '.rb'

          # `require_relative` is resolved relative to the current file's directory, so a
          # bare `foo`/`foo.rb` (no path separator) requires the current file itself. Compare
          # against the basename so this works whether `file_path` is relative or absolute.
          basename = File.basename(file_path, '.rb')
          required_feature == basename || required_feature == "#{basename}.rb"
        end
      end
    end
  end
end
