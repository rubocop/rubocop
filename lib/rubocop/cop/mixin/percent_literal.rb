# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling percent literals.
    module PercentLiteral
      include RangeHelp

      PERCENT_LITERAL_TYPES = %w[% %i %I %q %Q %r %s %w %W %x].freeze

      private

      def percent_literal?(node)
        return unless (begin_source = begin_source(node))
        begin_source.start_with?('%')
      end

      def process(node, *types)
        return unless percent_literal?(node) && types.include?(type(node))
        on_percent_literal(node)
      end

      def begin_source(node)
        node.loc.begin.source if node.loc.respond_to?(:begin) && node.loc.begin
      end

      def type(node)
        node.loc.begin.source[0..-2]
      end

      # A range containing only the contents of the percent literal (e.g. in
      # %i{1 2 3} this will be the range covering '1 2 3' only)
      def contents_range(node)
        range_between(node.loc.begin.end_pos, node.loc.end.begin_pos)
      end

      # ['a', 'b', 'c'] => %w(a b c)
      def correct_percent(node, char)
        words = node.children
        escape = words.any? { |w| needs_escaping?(w.children[0]) }
        char = char.upcase if escape
        delimiters = preferred_delimiters_for("%#{char}")
        contents = new_contents(node, escape, delimiters)

        lambda do |corrector|
          corrector.replace(
            node.source_range,
            "%#{char}#{delimiters[0]}#{contents}#{delimiters[1]}"
          )
        end
      end

      def new_contents(node, escape, delimiters)
        if node.multiline?
          autocorrect_multiline_words(node, escape, delimiters)
        else
          autocorrect_words(node, escape, delimiters)
        end
      end

      def autocorrect_multiline_words(node, escape, delimiters)
        base_line_number = node.first_line
        previous_line_number = base_line_number
        contents = node.children.map do |word_node|
          line_breaks = line_breaks(word_node,
                                    node.source,
                                    previous_line_number,
                                    base_line_number)
          previous_line_number = word_node.first_line
          content = escaped_content(word_node, escape, delimiters)
          line_breaks + content
        end
        contents << end_content(node.source)
        contents.join('')
      end

      def autocorrect_words(node, escape, delimiters)
        node.children.map do |word_node|
          content = word_node.children.first.to_s
          content = escape ? escape_string(content) : content
          delimiters.each do |delimiter|
            content.gsub!(delimiter, "\\#{delimiter}")
          end
          content
        end.join(' ')
      end

      def line_breaks(node, source, previous_line_number, base_line_number)
        source_in_lines = source.split("\n")
        if node.first_line == previous_line_number
          node.first_line == base_line_number ? '' : ' '
        else
          begin_line_number = previous_line_number - base_line_number + 1
          end_line_number = node.first_line - base_line_number + 1
          lines = source_in_lines[begin_line_number...end_line_number]
          "\n" + lines.join("\n").split(node.source).first
        end
      end

      def escaped_content(word_node, escape, delimiters)
        content = word_node.children.first.to_s
        content = escape_string(content) if escape
        delimiters.each do |delimiter|
          content.gsub!(delimiter, "\\#{delimiter}")
        end
        content
      end

      def end_content(source)
        result = /\A(\s*)\]/.match(source.split("\n").last)
        ("\n" + result[1]) if result
      end

      def ensure_valid_preferred_delimiters
        invalid = preferred_delimiters_config.keys -
                  (PERCENT_LITERAL_TYPES + %w[default])
        return if invalid.empty?

        raise ArgumentError,
              "Invalid preferred delimiter config key: #{invalid.join(', ')}"
      end

      def preferred_delimiters
        @preferred_delimiters ||=
          begin
            ensure_valid_preferred_delimiters

            if preferred_delimiters_config.key?('default')
              Hash[PERCENT_LITERAL_TYPES.map do |type|
                [type, preferred_delimiters_config[type] ||
                  preferred_delimiters_config['default']]
              end]
            else
              preferred_delimiters_config
            end
          end
      end

      def preferred_delimiters_config
        @config.for_cop('Style/PercentLiteralDelimiters')['PreferredDelimiters']
      end

      def preferred_delimiters_for(type)
        preferred_delimiters[type].split(//)
      end
    end
  end
end
