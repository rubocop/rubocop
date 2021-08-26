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
      #       :baz,
      #       key: value
      #
      #   foo(
      #     :bar,
      #     :baz,
      #     key: value
      #   )
      #
      #   # bad
      #
      #   foo :bar,
      #     :baz,
      #     key: value
      #
      #   foo(
      #     :bar,
      #       :baz,
      #       key: value
      #   )
      #
      # @example EnforcedStyle: with_fixed_indentation
      #   # good
      #
      #   foo :bar,
      #     :baz,
      #     key: value
      #
      #   # bad
      #
      #   foo :bar,
      #       :baz,
      #       key: value
      class ArgumentAlignment < Base
        include Alignment
        extend AutoCorrector

        ALIGN_PARAMS_MSG = 'Align the arguments of a method call if they span more than one line.'

        FIXED_INDENT_MSG = 'Use one level of indentation for arguments ' \
                           'following the first line of a multi-line method call.'

        def on_send(node)
          first_arg = node.first_argument
          return if !multiple_arguments?(node, first_arg) || (node.send_type? && node.method?(:[]=))

          if first_arg.hash_type? && !first_arg.braces?
            pairs = first_arg.pairs
            check_alignment(pairs, base_column(node, pairs.first))
          else
            check_alignment(node.arguments, base_column(node, first_arg))
          end
        end
        alias on_csend on_send

        private

        def multiple_arguments?(node, first_argument)
          return true if node.arguments.size >= 2

          first_argument&.hash_type? && first_argument.pairs.count >= 2
        end

        def autocorrect(corrector, node)
          AlignmentCorrector.correct(corrector, processed_source, node, column_delta)
        end

        def message(_node)
          fixed_indentation? ? FIXED_INDENT_MSG : ALIGN_PARAMS_MSG
        end

        def fixed_indentation?
          cop_config['EnforcedStyle'] == 'with_fixed_indentation'
        end

        def base_column(node, first_argument)
          if fixed_indentation? || first_argument.nil?
            lineno = target_method_lineno(node)
            line = node.source_range.source_buffer.source_line(lineno)
            indentation_of_line = /\S.*/.match(line).begin(0)
            indentation_of_line + configured_indentation_width
          else
            display_column(first_argument.source_range)
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
