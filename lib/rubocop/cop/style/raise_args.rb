# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks the args passed to `fail` and `raise`.
      class RaiseArgs < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          return unless command?(:raise, node) || command?(:fail, node)

          case style
          when :compact
            check_compact(node)
          when :exploded
            check_exploded(node)
          end
        end

        private

        def check_compact(node)
          _receiver, selector, *args = *node

          if args.size > 1
            add_offence(node, :expression, message(selector)) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def check_exploded(node)
          _receiver, selector, *args = *node

          if args.size == 1
            arg, = *args

            if arg.type == :send && arg.loc.selector.is?('new')
              _receiver, _selector, *constructor_args = *arg

              # Allow code like `raise Ex.new(arg1, arg2)`.
              if constructor_args.size <= 1
                add_offence(node, :expression, message(selector)) do
                  opposite_style_detected
                end
              end
            end
          else
            correct_style_detected
          end
        end

        def message(method)
          case style
          when :compact
            "Provide an exception object as an argument to #{method}."
          when :exploded
            "Provide an exception class and message as arguments to #{method}."
          end
        end
      end
    end
  end
end
