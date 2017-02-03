# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call or
      # definition are aligned.
      class AlignParameters < Cop
        include AutocorrectAlignment
        include OnMethodDef

        ALIGN_PARAMS_MSG = 'Align the parameters of a method %s if they span ' \
          'more than one line.'.freeze

        FIXED_INDENT_MSG = 'Use one level of indentation for parameters ' \
          'following the first line of a multi-line method %s.'.freeze

        def on_send(node)
          return if node.arguments.size < 2 || node.method?(:[]=)

          check_alignment(node.arguments, base_column(node, node.arguments))
        end

        def on_method_def(node, _method_name, args, _body)
          args = args.children

          return if args.size < 2

          check_alignment(args, base_column(node, args))
        end

        def message(node)
          type = node && node.parent.send_type? ? 'call' : 'definition'
          msg = fixed_indentation? ? FIXED_INDENT_MSG : ALIGN_PARAMS_MSG

          format(msg, type)
        end

        private

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
          if node.def_type? || node.defs_type?
            node.loc.keyword.line
          elsif node.loc.selector
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
