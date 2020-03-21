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
      # `Layout/Tab` cop.
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
      #   do_something_in_a_method_with_a_long_name(arg) if long_condition
      #
      #   # good
      #   do_stuff(bar) if condition
      #   Foo.do_something unless qux.empty?
      #
      #   if long_condition
      #     do_something_in_a_method_with_a_long_name(arg)
      #   end
      class IfUnlessModifier < Cop
        include StatementModifier
        include LineLengthHelp
        include IgnoredPattern

        MSG_USE_MODIFIER = 'Favor modifier `%<keyword>s` usage when having a ' \
                           'single-line body. Another good alternative is ' \
                           'the usage of control flow `&&`/`||`.'
        MSG_USE_NORMAL =
          'Modifier form of `%<keyword>s` makes the line too long.'

        ASSIGNMENT_TYPES = %i[lvasgn casgn cvasgn
                              gvasgn ivasgn masgn].freeze

        def on_if(node)
          msg = if eligible_node?(node)
                  MSG_USE_MODIFIER unless named_capture_in_condition?(node)
                elsif node.modifier_form? && too_long_single_line?(node)
                  MSG_USE_NORMAL
                end
          return unless msg

          add_offense(node,
                      location: :keyword,
                      message: format(msg, keyword: node.keyword))
        end

        def autocorrect(node)
          replacement = if node.modifier_form?
                          to_normal_form(node)
                        else
                          to_modifier_form(node)
                        end
          ->(corrector) { corrector.replace(node.source_range, replacement) }
        end

        private

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
          processed_source.comment_config
                          .cop_enabled_at_line?('Layout/LineLength', line)
        end

        def named_capture_in_condition?(node)
          node.condition.match_with_lvasgn_type?
        end

        def eligible_node?(node)
          !non_eligible_if?(node) && !node.chained? &&
            !node.nested_conditional? && single_line_as_modifier?(node)
        end

        def non_eligible_if?(node)
          node.ternary? || node.modifier_form? || node.elsif? || node.else?
        end

        def parenthesize?(node)
          # Parenthesize corrected expression if changing to modifier-if form
          # would change the meaning of the parent expression
          # (due to the low operator precedence of modifier-if)
          return false if node.parent.nil?
          return true if ASSIGNMENT_TYPES.include?(node.parent.type)

          node.parent.send_type? && !node.parent.parenthesized?
        end

        def to_modifier_form(node)
          expression = [node.body.source,
                        node.keyword,
                        node.condition.source,
                        first_line_comment(node)].compact.join(' ')

          parenthesize?(node) ? "(#{expression})" : expression
        end

        def to_normal_form(node)
          indentation = ' ' * node.source_range.column
          <<~RUBY.chomp
            #{node.keyword} #{node.condition.source}
            #{indentation}  #{node.body.source}
            #{indentation}end
          RUBY
        end

        def first_line_comment(node)
          comment =
            processed_source.find_comment { |c| c.loc.line == node.loc.line }

          comment ? comment.loc.expression.source : nil
        end
      end
    end
  end
end
