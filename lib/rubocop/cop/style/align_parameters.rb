# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call or
      # definition are aligned.
      class AlignParameters < Cop
        include AutocorrectAlignment
        include OnMethodDef

        def on_send(node)
          _receiver, method, *args = *node

          return if method == :[]=
          return if args.size < 2

          check_alignment(args, base_column(node, args))
        end

        def on_method_def(node, _method_name, args, _body)
          args = args.children
          return if args.size < 2
          check_alignment(args, base_column(node, args))
        end

        def message(node)
          type = node && node.parent.send_type? ? 'call' : 'definition'
          "Align the parameters of a method #{type} if they span " \
          'more than one line.'
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
            args.first.loc.column
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
