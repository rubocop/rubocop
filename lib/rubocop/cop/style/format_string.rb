# encoding: utf-8
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

        def on_send(node)
          add_offense(node, :selector) if offending_node?(node)
        end

        private

        def offending_node?(node)
          case style
          when :format
            sprintf?(node) || percent?(node)
          when :sprintf
            format?(node) || percent?(node)
          when :percent
            format?(node) || sprintf?(node)
          end
        end

        def format_method?(name, node)
          receiver, method_name, *args = *node

          # commands have no explicit receiver
          return false unless !receiver && method_name == name

          # we do an argument count check to reduce false positives
          args.size >= 2
        end

        def format?(node)
          format_method?(:format, node)
        end

        def sprintf?(node)
          format_method?(:sprintf, node)
        end

        def percent?(node)
          receiver_node, method_name, *arg_nodes = *node

          method_name == :% &&
            ([:str, :dstr].include?(receiver_node.type) ||
             arg_nodes[0].type == :array)
        end

        def message(node)
          _receiver_node, method_name, *_arg_nodes = *node

          preferred =
            if style == :percent
              'String#%'
            else
              style
            end

          method_name = 'String#%' if method_name == :%

          "Favor `#{preferred}` over `#{method_name}`."
        end
      end
    end
  end
end
