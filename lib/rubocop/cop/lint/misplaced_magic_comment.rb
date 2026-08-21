# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for magic comments placed where Ruby silently ignores them.
      #
      # The `encoding` magic comment is only honored on the first line of a file,
      # or on the second line when the first line is a shebang. Anywhere else it
      # is silently ignored - even directly below another comment or a blank line.
      #
      # Other magic comments (such as `frozen_string_literal`) are honored
      # anywhere before the first token of code, but are ignored after any code,
      # with a warning emitted only when running Ruby with `-w`.
      #
      # A magic comment misplaced ahead of a shebang also renders the shebang
      # ineffective, since a shebang is only recognized on the first line.
      #
      # NOTE: An `encoding` comment that is only preceded by other magic
      # comments is not flagged by this cop; that case is handled by
      # `Lint/OrderedMagicComments`. `shareable_constant_value` is never
      # flagged, as Ruby intentionally allows it mid-file with block scoping.
      #
      # @safety
      #   This cop's autocorrection is unsafe because moving the magic comment
      #   to its effective position activates it, which changes runtime
      #   behavior (e.g. the source encoding or string mutability).
      #
      # @example
      #   # bad
      #   # Documentation comment
      #   # encoding: ascii-8bit
      #   puts 'hello'
      #
      #   # good
      #   # encoding: ascii-8bit
      #   # Documentation comment
      #   puts 'hello'
      #
      #   # bad
      #   require 'foo'
      #   # frozen_string_literal: true
      #
      #   # good
      #   # frozen_string_literal: true
      #   require 'foo'
      #
      #   # bad
      #   # frozen_string_literal: true
      #   #!/usr/bin/env ruby
      #   puts 'hello'
      #
      #   # good
      #   #!/usr/bin/env ruby
      #   # frozen_string_literal: true
      #   puts 'hello'
      class MisplacedMagicComment < Base
        include RangeHelp
        extend AutoCorrector

        MSG_ENCODING = 'The `encoding` magic comment is ignored unless placed on the first ' \
                       'line (or below a shebang on the first line).'
        MSG_AFTER_CODE = 'The `%<directive>s` magic comment is ignored after any code.'
        MSG_ABOVE_SHEBANG = 'A magic comment above a shebang renders the shebang ineffective.'

        def on_new_investigation
          return if processed_source.buffer.source.empty?

          check_magic_comment_above_shebang
          processed_source.comments.each { |comment| check_comment(comment) }
        end

        private

        def check_comment(comment)
          return unless magic_comment_shaped?(comment.text)

          magic_comment = MagicComment.parse(comment.text)
          return unless magic_comment.valid?

          if magic_comment.encoding_specified?
            return unless known_encoding?(magic_comment.encoding)

            check_encoding_comment(comment)
          elsif magic_comment.frozen_string_literal_specified?
            check_top_block_comment(comment, 'frozen_string_literal')
          end
        end

        # The Emacs and Vim regexps in `MagicComment` match anywhere inside a
        # comment, which would flag documentation that merely quotes a magic
        # comment (e.g. `#   # -*- coding: UTF-8 -*-`). Require the magic
        # comment to start right after the `#`.
        def magic_comment_shaped?(text)
          /\A#(?![^#]*#)/.match?(text)
        end

        # Prose that happens to open with `Encoding:` parses as an encoding
        # comment (`# Encoding: force given encoding` yields `force`). Ruby
        # ignores a misplaced encoding comment entirely, so a name no encoding
        # answers to means the line is a comment, not a directive.
        def known_encoding?(name)
          Encoding.find(name)
          true
        rescue ArgumentError
          false
        end

        def shebang?
          processed_source.lines.first.to_s.start_with?('#!')
        end

        # First line that may carry an effective encoding comment.
        def effective_encoding_line
          shebang? ? 2 : 1
        end

        def first_code_token
          @first_code_token ||= processed_source.sorted_tokens.find { |token| !token.comment? }
        end

        def check_encoding_comment(comment)
          line = comment.source_range.line
          return if line == effective_encoding_line && comment_starts_line?(comment)
          # Leave `# frozen_string_literal: true` + `# encoding: x` runs at the
          # very top to Lint/OrderedMagicComments, which already reorders them.
          return if preceded_only_by_magic_comments?(comment)

          add_offense(comment, message: MSG_ENCODING) do |corrector|
            move_comment(corrector, comment, effective_encoding_line)
          end
        end

        def check_top_block_comment(comment, directive)
          return unless first_code_token
          return unless comment.source_range.begin_pos > first_code_token.begin_pos

          message = format(MSG_AFTER_CODE, directive: directive)
          add_offense(comment, message: message) do |corrector|
            move_comment(corrector, comment, effective_encoding_line)
          end
        end

        def check_magic_comment_above_shebang
          shebang_comment = processed_source.comments.find do |comment|
            comment.source_range.line > 1 && comment.text.start_with?('#!') &&
              comment.source_range.column.zero?
          end
          return unless shebang_comment
          # Only flag when what precedes the shebang is magic comments -
          # a `#!` comment deep inside a file is not an intended shebang.
          return unless preceded_only_by_magic_comments?(shebang_comment)

          add_offense(shebang_comment, message: MSG_ABOVE_SHEBANG)
        end

        def preceded_only_by_magic_comments?(comment)
          (1...comment.source_range.line).all? do |line_number|
            text = processed_source.lines[line_number - 1]
            (line_number == 1 && text.start_with?('#!')) || MagicComment.parse(text).valid?
          end
        end

        def comment_starts_line?(comment)
          processed_source.lines[comment.source_range.line - 1].lstrip.start_with?('#')
        end

        def move_comment(corrector, comment, target_line)
          removal_range = if comment_starts_line?(comment)
                            range_by_whole_lines(comment.source_range, include_final_newline: true)
                          else
                            range_with_surrounding_space(comment.source_range, side: :left)
                          end
          corrector.remove(removal_range)
          target_range = processed_source.buffer.line_range(target_line)
          if comment.source_range.line < target_line
            corrector.insert_after(target_range, "\n#{comment.text}")
          else
            corrector.insert_before(target_range, "#{comment.text}\n")
          end
        end
      end
    end
  end
end
