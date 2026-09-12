# frozen_string_literal: true

module RuboCop
  module Cop
    # Reads the documentation comment a cop carries above its class definition
    # and splits it into the sections worth showing on their own.
    #
    # YARD is a development dependency, so the comment is read straight from the
    # source rather than through a doclet.
    # @api private
    class CopDocumentation
      TAG = /^@(\w+)\s*(.*)$/.freeze

      def initialize(cop_class)
        @cop_class = cop_class
      end

      # @return [Array<Array(String, Array<String>)>] title and body per section
      def sections
        comment = comment_lines
        return [] if comment.empty?

        prose, tagged = split_on_first_tag(comment)

        [['Details', strip_blank(prose)], *tagged_sections(tagged)].reject { |_, b| b.empty? }
      end

      private

      def comment_lines
        path, line = source_location
        return [] unless path && File.file?(path)

        lines = File.readlines(path, chomp: true)
        collect_comment_above(lines, line - 2)
      end

      def source_location
        name = @cop_class.name
        return [] unless name

        Module.const_source_location(name) || []
      rescue NameError
        []
      end

      # Walks up from the class definition for as long as the lines are comments.
      def collect_comment_above(lines, index)
        block = []
        while index >= 0 && lines[index].match?(/^\s*#/)
          block.unshift(lines[index].sub(/^\s*# ?/, ''))
          index -= 1
        end
        block
      end

      def split_on_first_tag(comment)
        first_tag = comment.index { |line| line.match?(TAG) }
        return [comment, []] unless first_tag

        [comment[0...first_tag], comment[first_tag..]]
      end

      def tagged_sections(lines)
        lines.slice_before { |line| line.match?(TAG) }.map do |(head, *body)|
          tag, argument = head.match(TAG).captures
          [section_title(tag, argument), strip_blank(body)]
        end
      end

      def section_title(tag, argument)
        title = tag.capitalize
        argument.empty? ? title : "#{title}: #{argument}"
      end

      def strip_blank(lines)
        lines.drop_while(&:empty?).reverse.drop_while(&:empty?).reverse
      end
    end
  end
end
