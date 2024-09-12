# frozen_string_literal: true

module RuboCop
  module Cop
    module Test
      # This cop allows us to test the {AlignmentCorrector}. A node that is
      # annotated with a comment of the form `# << delta` or `# >> delta` where
      # `delta` is an integer will be shifted by `delta` columns in the
      # indicated direction.
      class AlignmentDirective < RuboCop::Cop::Base
        extend AutoCorrector

        MSG = 'Indent this node.'

        def on_new_investigation
          processed_source.ast_with_comments.each do |node, comments|
            comments.each do |c|
              if (delta = delta(c))
                add_offense(node) { |corrector| autocorrect(corrector, node, c, delta) }
              end
            end
          end
        end

        private

        def autocorrect(corrector, node, comment, delta)
          AlignmentCorrector.correct(corrector, processed_source, node, delta)
          corrector.replace(comment, '#')
        end

        def delta(comment)
          /\A#\s*(<<|>>)\s*(\d+)\s*\z/.match(comment.text) do |m|
            (m[1] == '<<' ? -1 : 1) * m[2].to_i
          end
        end
      end
    end
  end
end
