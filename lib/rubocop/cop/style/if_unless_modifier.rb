# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `if` and `unless` statements that would fit on one line if
      # written as modifier `if`/`unless`. The cop also checks for modifier
      # `if`/`unless` lines that exceed the maximum line length.
      #
      # The maximum line length is configured in the `Layout/LineLength`
      # cop. The tab size is configured in the `IndentationWidth` of the
      # `Layout/IndentationStyle` cop.
      #
      # @example
      #   # bad
      #   if condition
      #     do_stuff(bar)
      #   end
      #
      #   unless qux.empty?
      #     Foo.do_something
      #   end
      #
      #   do_something_with_a_long_name(arg) if long_condition_that_prevents_code_fit_on_single_line
      #
      #   # good
      #   do_stuff(bar) if condition
      #   Foo.do_something unless qux.empty?
      #
      #   if long_condition_that_prevents_code_fit_on_single_line
      #     do_something_with_a_long_name(arg)
      #   end
      #
      #   if short_condition # a long comment that makes it too long if it were just a single line
      #     do_something
      #   end
      class IfUnlessModifier < Base
        include StatementModifier
        include LineLengthHelp
        include IgnoredPattern
        include RangeHelp
        extend AutoCorrector

        MSG_USE_MODIFIER = 'Favor modifier `%<keyword>s` usage when having a ' \
                           'single-line body. Another good alternative is ' \
                           'the usage of control flow `&&`/`||`.'
        MSG_USE_NORMAL = 'Modifier form of `%<keyword>s` makes the line too long.'

        def self.autocorrect_incompatible_with
          [Style::SoleNestedConditional]
        end

        def on_if(node)
          msg = if single_line_as_modifier?(node) && !named_capture_in_condition?(node)
                  MSG_USE_MODIFIER
                elsif too_long_due_to_modifier?(node)
                  MSG_USE_NORMAL
                end
          return unless msg

          add_offense(node.loc.keyword, message: format(msg, keyword: node.keyword)) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def autocorrect(corrector, node)
          replacement = if node.modifier_form?
                          indentation = ' ' * node.source_range.column
                          last_argument = node.if_branch.last_argument

                          if last_argument.respond_to?(:heredoc?) && last_argument.heredoc?
                            heredoc = extract_heredoc_from(last_argument)
                            remove_heredoc(corrector, heredoc)
                            to_normal_form_with_heredoc(node, indentation, heredoc)
                          else
                            to_normal_form(node, indentation)
                          end
                        else
                          to_modifier_form(node)
                        end
          corrector.replace(node, replacement)
        end

        def too_long_due_to_modifier?(node)
          node.modifier_form? && too_long_single_line?(node) &&
            !another_statement_on_same_line?(node)
        end

        def ignored_patterns
          config.for_cop('Layout/LineLength')['IgnoredPatterns'] || []
        end

        def too_long_single_line?(node)
          return false unless max_line_length

          range = node.source_range
          return false unless range.first_line == range.last_line
          return false unless line_length_enabled_at_line?(range.first_line)

          line = range.source_line
          return false if line_length(line) <= max_line_length

          too_long_line_based_on_config?(range, line)
        end

        def too_long_line_based_on_config?(range, line)
          return false if matches_ignored_pattern?(line)

          too_long = too_long_line_based_on_ignore_cop_directives?(range, line)
          return too_long unless too_long == :undetermined

          too_long_line_based_on_allow_uri?(line)
        end

        def too_long_line_based_on_ignore_cop_directives?(range, line)
          if ignore_cop_directives? && directive_on_source_line?(range.line - 1)
            return line_length_without_directive(line) > max_line_length
          end

          :undetermined
        end

        def too_long_line_based_on_allow_uri?(line)
          if allow_uri?
            uri_range = find_excessive_uri_range(line)
            return false if uri_range && allowed_uri_position?(line, uri_range)
          end

          true
        end

        def line_length_enabled_at_line?(line)
          processed_source.comment_config.cop_enabled_at_line?('Layout/LineLength', line)
        end

        def named_capture_in_condition?(node)
          node.condition.match_with_lvasgn_type?
        end

        def non_eligible_node?(node)
          non_simple_if_unless?(node) || node.chained? || node.nested_conditional? || super
        end

        def non_simple_if_unless?(node)
          node.ternary? || node.elsif? || node.else?
        end

        def another_statement_on_same_line?(node)
          line_no = node.source_range.last_line

          # traverse the AST upwards until we find a 'begin' node
          # we want to look at the following child and see if it is on the
          #   same line as this 'if' node
          while node && !node.begin_type?
            index = node.sibling_index
            node  = node.parent
          end

          node && (sibling = node.children[index + 1]) && sibling.source_range.first_line == line_no
        end

        def to_normal_form(node, indentation)
          <<~RUBY.chomp
            #{node.keyword} #{node.condition.source}
            #{indentation}  #{node.body.source}
            #{indentation}end
          RUBY
        end

        def to_normal_form_with_heredoc(node, indentation, heredoc)
          heredoc_body, heredoc_end = heredoc

          <<~RUBY.chomp
            #{node.keyword} #{node.condition.source}
            #{indentation}  #{node.body.source}
            #{indentation}  #{heredoc_body.source.chomp}
            #{indentation}  #{heredoc_end.source.chomp}
            #{indentation}end
          RUBY
        end

        def extract_heredoc_from(last_argument)
          heredoc_body = last_argument.loc.heredoc_body
          heredoc_end = last_argument.loc.heredoc_end

          [heredoc_body, heredoc_end]
        end

        def remove_heredoc(corrector, heredoc)
          heredoc.each do |range|
            corrector.remove(range_by_whole_lines(range, include_final_newline: true))
          end
        end
      end
    end
  end
end
