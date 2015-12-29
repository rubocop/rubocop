# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for checking whether an AST node/token is aligned
    # with something on a preceding or following line
    module PrecedingFollowingAlignment
      def allow_for_alignment?
        cop_config['AllowForAlignment']
      end

      def aligned_with_something?(range)
        aligned_with_adjacent_line?(range, method(:aligned_token?))
      end

      def aligned_with_operator?(range)
        aligned_with_adjacent_line?(range, method(:aligned_operator?))
      end

      def aligned_with_adjacent_line?(range, predicate)
        # minus 2 because node.loc.line is zero-based
        pre  = (range.line - 2).downto(0)
        post = range.line.upto(processed_source.lines.size - 1)
        return true if aligned_with_line?(pre, range, &predicate) ||
                       aligned_with_line?(post, range, &predicate)

        # If no aligned token was found, search for an aligned token on the
        # nearest line with the same indentation as the checked line.
        base_indentation = processed_source.lines[range.line - 1] =~ /\S/
        aligned_with_line?(pre, range, base_indentation, &predicate) ||
          aligned_with_line?(post, range, base_indentation, &predicate)
      end

      def aligned_with_line?(line_nos, range, indent = nil)
        comment_lines = processed_source.comments.map(&:loc).select do |r|
          begins_its_line?(r.expression)
        end.map(&:line)

        line_nos.each do |lineno|
          next if comment_lines.include?(lineno + 1)
          line = processed_source.lines[lineno]
          next if line =~ /\A\s*\Z/
          next if indent && indent != (line =~ /\S/)
          return yield(range, line)
        end
        false
      end

      def aligned_token?(range, line)
        aligned_words?(range, line) ||
          aligned_char?(range, line) ||
          aligned_assignment?(range, line)
      end

      def aligned_operator?(range, line)
        (aligned_identical?(range, line) || aligned_assignment?(range, line))
      end

      def aligned_words?(range, line)
        line[range.column - 1, 2] =~ /\s\S/
      end

      def aligned_char?(range, line)
        line[range.column] == range.source[0]
      end

      def aligned_assignment?(range, line)
        range.source[-1] == '=' && line[range.last_column - 1] == '='
      end

      def aligned_identical?(range, line)
        range.source == line[range.column, range.size]
      end
    end
  end
end
