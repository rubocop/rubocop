# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective
# rubocop:disable Style/DoubleCopDisableDirective

module RuboCop
  module Cop
    module Style
      # Detects double disable comments on one line. This is mostly to catch
      # automatically generated comments that need to be regenerated.
      #
      # @example
      #   # bad
      #   def f # rubocop:disable Style/For # rubocop:disable Metrics/AbcSize
      #   end
      #
      #   # good
      #   # rubocop:disable Metrics/AbcSize
      #   def f # rubocop:disable Style/For
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      #   # if both fit on one line
      #   def f # rubocop:disable Style/For, Metrics/AbcSize
      #   end
      #
      class DoubleCopDisableDirective < Cop
        # rubocop:enable Style/For, Style/DoubleCopDisableDirective
        # rubocop:enable Lint/RedundantCopDisableDirective, Metrics/AbcSize
        MSG = 'More than one disable comment on one line.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next unless comment.text.scan(/# rubocop:(?:disable|todo)/).size > 1

            add_offense(comment)
          end
        end

        def autocorrect(comment)
          prefix = if comment.text.start_with?('# rubocop:disable')
                     '# rubocop:disable'
                   else
                     '# rubocop:todo'
                   end

          lambda do |corrector|
            corrector.replace(comment,
                              comment.text[/#{prefix} \S+/])
          end
        end
      end
    end
  end
end
