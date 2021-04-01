# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of `if-else` and ternary operators with a negated condition
      # which can be simplified by inverting condition and swapping branches.
      #
      # @example
      #   # bad
      #   if !x
      #     do_something
      #   else
      #     do_something_else
      #   end
      #
      #   # good
      #   if x
      #     do_something_else
      #   else
      #     do_something
      #   end
      #
      #   # bad
      #   !x ? do_something : do_something_else
      #
      #   # good
      #   x ? do_something_else : do_something
      #
      class NegatedIfElseCondition < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Invert the negated condition and swap the %<type>s branches.'

        NEGATED_EQUALITY_METHODS = %i[!= !~].freeze

        def_node_matcher :double_negation?, '(send (send _ :!) :!)'

        def self.autocorrect_incompatible_with
          [Style::InverseMethods, Style::Not]
        end

        def on_new_investigation
          @corrected_nodes = nil
        end

        def on_if(node)
          return unless if_else?(node)

          condition = node.condition
          return if double_negation?(condition) || !negated_condition?(condition)

          type = node.ternary? ? 'ternary' : 'if-else'
          add_offense(node, message: format(MSG, type: type)) do |corrector|
            unless corrected_ancestor?(node)
              correct_negated_condition(corrector, condition)
              swap_branches(corrector, node)

              @corrected_nodes ||= Set.new.compare_by_identity
              @corrected_nodes.add(node)
            end
          end
        end

        private

        def if_else?(node)
          else_branch = node.else_branch
          !node.elsif? && else_branch && (!else_branch.if_type? || !else_branch.elsif?)
        end

        def negated_condition?(node)
          node.send_type? &&
            (node.negation_method? || NEGATED_EQUALITY_METHODS.include?(node.method_name))
        end

        def corrected_ancestor?(node)
          node.each_ancestor(:if).any? { |ancestor| @corrected_nodes&.include?(ancestor) }
        end

        def correct_negated_condition(corrector, node)
          receiver, method_name, rhs = *node
          replacement =
            if node.negation_method?
              receiver.source
            else
              inverted_method = method_name.to_s.sub('!', '=')
              "#{receiver.source} #{inverted_method} #{rhs.source}"
            end

          corrector.replace(node, replacement)
        end

        def swap_branches(corrector, node)
          if node.if_branch.nil?
            corrector.remove(range_by_whole_lines(node.loc.else, include_final_newline: true))
          else
            corrector.replace(node.if_branch, node.else_branch.source)
            corrector.replace(node.else_branch, node.if_branch.source)
          end
        end
      end
    end
  end
end
