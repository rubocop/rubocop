# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Enforces the cop description to start with a word such as verb.
      #
      # @example
      #   # bad
      #   # This cop checks ....
      #   class SomeCop < Base
      #     ....
      #   end
      #
      #   # good
      #   # Checks ...
      #   class SomeCop < Base
      #     ...
      #   end
      #
      class CopDescription < Base
        extend AutoCorrector

        MSG = 'Description should be started with %<suggestion>s instead of `This cop ...`.'

        SPECIAL_WORDS = %w[is can could should will would must may].freeze
        COP_DESC_OFFENSE_REGEX = \
          /^\s+# This cop (?<special>#{SPECIAL_WORDS.join('|')})?\s*(?<word>.+?) .*/.freeze
        REPLACEMENT_REGEX = /^\s+# This cop (#{SPECIAL_WORDS.join('|')})?\s*(.+?) /.freeze

        def on_class(node)
          return unless (module_node = node.parent)

          description_beginning = first_comment_line(module_node)
          return unless description_beginning

          start_with_subject = description_beginning.match(COP_DESC_OFFENSE_REGEX)
          return unless start_with_subject

          suggestion = start_with_subject['word']&.capitalize
          range = range(module_node, description_beginning)
          suggestion_for_message = suggestion_for_message(suggestion, start_with_subject)
          message = format(MSG, suggestion: suggestion_for_message)

          add_offense(range, message: message) do |corrector|
            if suggestion && !start_with_subject['special']
              replace_with_suggestion(corrector, range, suggestion, description_beginning)
            end
          end
        end

        private

        def replace_with_suggestion(corrector, range, suggestion, description_beginning)
          replacement = description_beginning.gsub(REPLACEMENT_REGEX, "#{suggestion} ")
          corrector.replace(range, replacement)
        end

        def range(node, comment_line)
          source_buffer = node.loc.expression.source_buffer

          begin_pos = node.loc.expression.begin_pos
          begin_pos += comment_index(node, comment_line)
          end_pos = begin_pos + comment_body(comment_line).length

          Parser::Source::Range.new(source_buffer, begin_pos, end_pos)
        end

        def suggestion_for_message(suggestion, match_data)
          if suggestion && !match_data['special']
            "`#{suggestion}`"
          else
            'a word such as verb'
          end
        end

        def first_comment_line(node)
          node.loc.expression.source.lines.find { |line| comment_line?(line) }
        end

        def comment_body(comment_line)
          comment_line.gsub(/^\s*# /, '')
        end

        def comment_index(node, comment_line)
          body = comment_body(comment_line)
          node.loc.expression.source.index(body)
        end

        def relevant_file?(file)
          file.match?(%r{/cop/.*\.rb\z})
        end
      end
    end
  end
end
