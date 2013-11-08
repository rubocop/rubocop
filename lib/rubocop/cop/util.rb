# encoding: utf-8

module Rubocop
  module Cop
    # This module contains a collection of useful utility methods.
    module Util
      extend AST::Sexp

      PROC_NEW_NODE = s(:send, s(:const, nil, :Proc), :new)

      module_function

      def strip_quotes(str)
        if str[0] == '"' || str[0] == "'"
          str[0] = ''
          str[-1] = ''
        else
          # we're dealing with %q or %Q
          str[0, 3] = ''
          str[-1] = ''
        end

        str
      end

      def block_length(block_node)
        block_node.loc.end.line - block_node.loc.begin.line
      end

      def source_length(source, count_comments = nil)
        lines = source.lines.to_a[1...-1]

        return 0 unless lines

        lines.reject!(&:blank?)

        lines.reject! { |line| comment_line?(line) } unless count_comments

        lines.size
      end

      def comment_line?(line_source)
        line_source =~ /^\s*#/
      end

      def line_range(arg)
        source_range = case arg
                       when Parser::Source::Range
                         arg
                       when Parser::AST::Node
                         arg.loc.expression
                       else
                         fail ArgumentError, "Invalid argument #{arg}"
                       end

        source_range.begin.line..source_range.end.line
      end

      def const_name(node)
        return nil if node.nil? || node.type != :const

        const_names = []
        const_node = node

        loop do
          namespace_node, name = *const_node
          const_names << name
          break unless namespace_node
          break unless namespace_node.is_a?(Parser::AST::Node)
          break if namespace_node.type == :cbase
          const_node = namespace_node
        end

        const_names.reverse.join('::')
      end

      def command?(name, node)
        return unless node.type == :send

        receiver, method_name, _args = *node

        # commands have no explicit receiver
        !receiver && method_name == name
      end

      def lambda?(node)
        fail 'Not a block node' unless node.type == :block

        send_node, _block_args, _block_body = *node

        command?(:lambda, send_node)
      end

      def proc?(node)
        fail 'Not a block node' unless node.type == :block

        send_node, _block_args, _block_body = *node

        command?(:proc, send_node) || send_node == PROC_NEW_NODE
      end

      def lambda_or_proc?(node)
        lambda?(node) || proc?(node)
      end

      def on_node(syms, sexp, excludes = [])
        yield sexp if Array(syms).include?(sexp.type)

        return if Array(excludes).include?(sexp.type)

        sexp.children.each do |elem|
          if elem.is_a?(Parser::AST::Node)
            on_node(syms, elem, excludes) { |s| yield s }
          end
        end
      end

      def source_range(source_buffer, preceding_lines, begin_column,
                       column_count)
        newline_length = 1
        begin_pos = preceding_lines.reduce(0) do |a, e|
          a + e.length + newline_length
        end + begin_column
        Parser::Source::Range.new(source_buffer, begin_pos,
                                  begin_pos + column_count)
      end

      def range_with_surrounding_space(range, side = :both)
        src = @processed_source.buffer.source
        go_left = side == :left || side == :both
        go_right = side == :right || side == :both
        begin_pos = range.begin_pos
        begin_pos -= 1 while go_left && src[begin_pos - 1] =~ /[ \t]/
        end_pos = range.end_pos
        end_pos += 1 while go_right && src[end_pos] =~ /[ \t]/
        Parser::Source::Range.new(@processed_source.buffer, begin_pos, end_pos)
      end
    end
  end
end
