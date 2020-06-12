# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling Regexp literals.
    module RegexpLiteralHelp
      private

      def freespace_mode_regexp?(node)
        regopt = node.children.find(&:regopt_type?)

        regopt.children.include?(:x)
      end

      def pattern_source(node)
        freespace_mode = freespace_mode_regexp?(node)

        node.children.reject(&:regopt_type?).map do |child|
          source_with_comments_and_interpolations_blanked(child, freespace_mode)
        end.join
      end

      def source_with_comments_and_interpolations_blanked(child, freespace_mode)
        source = child.source

        # We don't want to consider the contents of interpolations or free-space mode comments as
        # part of the pattern source, but need to preserve their width, to allow offsets to
        # correctly line up with the original source: spaces have no effect, and preserve width.
        if child.begin_type?
          replace_match_with_spaces(source, /.*/) # replace all content
        elsif freespace_mode
          replace_match_with_spaces(source, /(?<!\\)#.*/) # replace any comments
        else
          source
        end
      end

      def replace_match_with_spaces(source, pattern)
        source.sub(pattern) { ' ' * Regexp.last_match[0].length }
      end
    end
  end
end
