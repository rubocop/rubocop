# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Access modifiers should be surrounded by blank lines.
      #
      # @example
      #
      #   # bad
      #   class Foo
      #     def bar; end
      #     private
      #     def baz; end
      #   end
      #
      #   # good
      #   class Foo
      #     def bar; end
      #
      #     private
      #
      #     def baz; end
      #   end
      class EmptyLinesAroundAccessModifier < Cop
        include RangeHelp

        MSG_AFTER = 'Keep a blank line after `%<modifier>s`.'.freeze
        MSG_BEFORE_AND_AFTER = 'Keep a blank line before and after ' \
                               '`%<modifier>s`.'.freeze

        def on_class(node)
          _name, superclass, _body = *node

          @class_or_module_def_line = if superclass
                                        superclass.first_line
                                      else
                                        node.source_range.first_line
                                      end
        end

        def on_module(node)
          @class_or_module_def_line = node.source_range.first_line
        end

        def on_sclass(node)
          self_node, _body = *node

          @class_or_module_def_line = self_node.source_range.first_line
        end

        def on_send(node)
          return unless node.bare_access_modifier?

          return if empty_lines_around?(node)

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            send_line = node.first_line
            next_line = processed_source[send_line]
            line = range_by_whole_lines(node.source_range)

            unless previous_line_empty?(send_line)
              corrector.insert_before(line, "\n")
            end

            unless next_line_empty?(next_line)
              corrector.insert_after(line, "\n")
            end
          end
        end

        private

        def previous_line_ignoring_comments(processed_source, send_line)
          processed_source[0..send_line - 2].reverse.find do |line|
            !comment_line?(line)
          end
        end

        def previous_line_empty?(send_line)
          previous_line = previous_line_ignoring_comments(processed_source,
                                                          send_line)

          block_start?(previous_line) ||
            class_def?(send_line) ||
            previous_line.blank?
        end

        def next_line_empty?(next_line)
          body_end?(next_line) || next_line.blank?
        end

        def empty_lines_around?(node)
          send_line = node.first_line

          next_line = processed_source[send_line]

          previous_line_empty?(send_line) && next_line_empty?(next_line)
        end

        def class_def?(line)
          return false unless @class_or_module_def_line

          line == @class_or_module_def_line + 1
        end

        def block_start?(line)
          line.match(/ (do|{)( \|.*?\|)?\s?$/)
        end

        def body_end?(line)
          line =~ /^\s*end\b/
        end

        def message(node)
          send_line = node.first_line
          previous_line = processed_source[send_line - 2]

          if block_start?(previous_line) ||
             class_def?(send_line)
            format(MSG_AFTER, modifier: node.loc.selector.source)
          else
            format(MSG_BEFORE_AND_AFTER, modifier: node.loc.selector.source)
          end
        end
      end
    end
  end
end
