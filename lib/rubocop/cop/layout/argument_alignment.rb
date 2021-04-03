# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Here we check if the arguments on a multi-line method
      # definition are aligned.
      #
      # @example EnforcedStyle: with_first_argument (default)
      #   # good
      #
      #   foo :bar,
      #       :baz
      #
      #   foo(
      #     :bar,
      #     :baz
      #   )
      #
      #   # bad
      #
      #   foo :bar,
      #     :baz
      #
      #   foo(
      #     :bar,
      #       :baz
      #   )
      #
      # @example EnforcedStyle: with_fixed_indentation
      #   # good
      #
      #   foo :bar,
      #     :baz
      #
      #   # bad
      #
      #   foo :bar,
      #       :baz
      class ArgumentAlignment < Base
        include Alignment
        extend AutoCorrector

        ALIGN_PARAMS_MSG = 'Align the arguments of a method call if they span more than one line.'

        FIXED_INDENT_MSG = 'Use one level of indentation for arguments ' \
          'following the first line of a multi-line method call.'

        def on_send(node)
          return if node.arguments.size < 2 || node.send_type? && node.method?(:[]=)

          check_alignment(node.arguments, base_column(node, node.arguments))
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, node)
          AlignmentCorrector.correct(corrector, processed_source, node, column_delta)
        end

        def message(_node)
          fixed_indentation? ? FIXED_INDENT_MSG : ALIGN_PARAMS_MSG
        end

        def fixed_indentation?
          cop_config['EnforcedStyle'] == 'with_fixed_indentation'
        end

        def base_column(node, args)
          if fixed_indentation?
            lineno = target_method_lineno(node)
            line = node.source_range.source_buffer.source_line(lineno)
            indentation_of_line = /\S.*/.match(line).begin(0)
            indentation_of_line + configured_indentation_width
          else
            display_column(args.first.source_range)
          end
        end

        def target_method_lineno(node)
          if node.loc.selector
            node.loc.selector.line
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            node.loc.begin.line
          end
        end
      end
    end
  end
end
