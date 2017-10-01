# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of a single string formatting utility.
      # Valid options include Kernel#format, Kernel#sprintf and String#%.
      #
      # The detection of String#% cannot be implemented in a reliable
      # manner for all cases, so only two scenarios are considered -
      # if the first argument is a string literal and if the second
      # argument is an array literal.
      class FormatString < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Favor `%s` over `%s`.'.freeze

        def_node_matcher :formatter, <<-PATTERN
        {
          (send nil? ${:sprintf :format} _ _ ...)
          (send {str dstr} $:% ... )
          (send !nil? $:% {array hash})
        }
        PATTERN

        def on_send(node)
          formatter(node) do |selector|
            detected_style = selector == :% ? :percent : selector

            return if detected_style == style

            add_offense(node, :selector, message(detected_style))
          end
        end

        def message(detected_style)
          format(MSG, method_name(style), method_name(detected_style))
        end

        def method_name(style_name)
          style_name == :percent ? 'String#%' : style_name
        end

        def autocorrect(node)
          lambda do |corrector|
            _receiver, detected_method = *node

            case detected_method
            when :%
              autocorrect_from_percent(corrector, node)
            when :format, :sprintf
              case style
              when :percent
                autocorrect_to_percent(corrector, node)
              when :format, :sprintf
                corrector.replace(node.loc.selector, style.to_s)
              end
            end
          end
        end

        private

        def autocorrect_from_percent(corrector, node)
          receiver, _method, args = *node
          format = receiver.source
          args = if args.array_type? || args.hash_type?
                   args.children.map(&:source).join(', ')
                 else
                   args.source
                 end
          corrected = "#{style}(#{format}, #{args})"
          corrector.replace(node.loc.expression, corrected)
        end

        def autocorrect_to_percent(corrector, node)
          _nil, _method, format, *args = *node
          format = format.source
          args   = if args.one?
                     arg = args.first
                     if arg.hash_type?
                       "{ #{arg.source} }"
                     else
                       arg.source
                     end
                   else
                     "[#{args.map(&:source).join(', ')}]"
                   end
          corrected = "#{format} % #{args}"
          corrector.replace(node.loc.expression, corrected)
        end
      end
    end
  end
end
