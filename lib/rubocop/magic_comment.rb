# frozen_string_literal: true

module RuboCop
  # Parse different formats of magic comments.
  #
  # @abstract parent of three different magic comment handlers
  class MagicComment
    # @see https://git.io/vMC1C IRB's pattern for matching magic comment tokens
    TOKEN = /[[:alnum:]\-_]+/

    # Detect magic comment format and pass it to the appropriate wrapper.
    #
    # @param comment [String]
    #
    # @return [RuboCop::MagicComment]
    def self.parse(comment)
      case comment
      when EmacsComment::FORMAT then EmacsComment.new(comment)
      when VimComment::FORMAT   then VimComment.new(comment)
      else
        SimpleComment.new(comment)
      end
    end

    def initialize(comment)
      @comment = comment
    end

    def any?
      frozen_string_literal_specified? || encoding_specified?
    end

    # Does the magic comment enable the frozen string literal feature.
    #
    # Test whether the frozen string literal value is `true`. Cannot
    # just return `frozen_string_literal` since an invalid magic comment
    # like `# frozen_string_literal: yes` is possible and the truthy value
    # `'yes'` does not actually enable the feature
    #
    # @return [Boolean]
    def frozen_string_literal?
      frozen_string_literal == true
    end

    # Was a magic comment for the frozen string literal found?
    #
    # @return [Boolean]
    def frozen_string_literal_specified?
      specified?(frozen_string_literal)
    end

    # Expose the `frozen_string_literal` value coerced to a boolean if possible.
    #
    # @return [Boolean] if value is `true` or `false`
    # @return [nil] if frozen_string_literal comment isn't found
    # @return [String] if comment is found but isn't true or false
    def frozen_string_literal
      return unless (setting = extract_frozen_string_literal)

      case setting
      when 'true'  then true
      when 'false' then false
      else
        setting
      end
    end

    def encoding_specified?
      specified?(encoding)
    end

    private

    def specified?(value)
      !value.nil?
    end

    # Match the entire comment string with a pattern and take the first capture.
    #
    # @param pattern [Regexp]
    #
    # @return [String] if pattern matched
    # @return [nil] otherwise
    def extract(pattern)
      @comment[pattern, 1]
    end

    # Parent to Vim and Emacs magic comment handling.
    #
    # @abstract
    class EditorComment < MagicComment
      private

      # Find a token starting with the provided keyword and extract its value.
      #
      # @param keyword [String]
      #
      # @return [String] extracted value if it is found
      # @return [nil] otherwise
      def match(keyword)
        pattern = /\A#{keyword}\s*#{self.class::OPERATOR}\s*(#{TOKEN})\z/

        tokens.each do |token|
          next unless (value = token[pattern, 1])

          return value.downcase
        end

        nil
      end

      # Individual tokens composing an editor specific comment string.
      #
      # @return [Array<String>]
      def tokens
        extract(self.class::FORMAT).split(self.class::SEPARATOR).map(&:strip)
      end
    end

    # Wrapper for Emacs style magic comments.
    #
    # @example Emacs style comment
    #   comment = RuboCop::MagicComment.parse(
    #     '# -*- encoding: ASCII-8BIT; frozen_string_literal: true -*-'
    #   )
    #
    #   comment.encoding              # => 'ascii-8bit'
    #   comment.frozen_string_literal # => true
    #
    # @see https://www.gnu.org/software/emacs/manual/html_node/emacs/Specify-Coding.html
    # @see https://git.io/vMCXh Emacs handling in Ruby's parse.y
    class EmacsComment < EditorComment
      FORMAT    = /\-\*\-(.+)\-\*\-/
      SEPARATOR = ';'.freeze
      OPERATOR  = ':'.freeze

      def encoding
        match('encoding')
      end

      private

      def extract_frozen_string_literal
        match('frozen_string_literal')
      end
    end

    # Wrapper for Vim style magic comments.
    #
    # @example Vim style comment
    #   comment = RuboCop::MagicComment.parse(
    #     '# vim: filetype=ruby, fileencoding=ascii-8bit'
    #   )
    #
    #   comment.encoding # => 'ascii-8bit'
    class VimComment < EditorComment
      FORMAT    = /#\s*vim:\s*(.+)/
      SEPARATOR = ', '.freeze
      OPERATOR  = '='.freeze

      # For some reason the fileencoding keyword only works if there
      # is at least one other token included in the string. For example
      #
      #    # works
      #      # vim: foo=bar, fileencoding=ascii-8bit
      #
      #    # does nothing
      #      # vim: foo=bar, fileencoding=ascii-8bit
      #
      def encoding
        match('fileencoding') if tokens.size > 1
      end

      # Vim comments cannot specify frozen string literal behavior.
      def frozen_string_literal; end
    end

    # Wrapper for regular magic comments not bound to an editor.
    #
    # Simple comments can only specify one setting per comment.
    #
    # @example frozen string literal comments
    #   comment1 = RuboCop::MagicComment.parse('# frozen_string_literal: true')
    #   comment1.frozen_string_literal # => true
    #   comment1.encoding              # => nil
    #
    # @example encoding comments
    #   comment2 = RuboCop::MagicComment.parse('# encoding: utf-8')
    #   comment2.frozen_string_literal # => nil
    #   comment2.encoding              # => 'utf-8'
    class SimpleComment < MagicComment
      # Match `encoding` or `coding`
      def encoding
        extract(/\b(?:en)?coding: (#{TOKEN})/i)
      end

      private

      # Extract `frozen_string_literal`.
      #
      # The `frozen_string_literal` magic comment only works if it
      # is the only text in the comment.
      #
      # Case-insensitive and dashes/underscores are acceptable.
      # @see https://git.io/vM7Mg
      def extract_frozen_string_literal
        extract(/\A#\s*frozen[_-]string[_-]literal:\s*(#{TOKEN})\s*\z/i)
      end
    end
  end
end
