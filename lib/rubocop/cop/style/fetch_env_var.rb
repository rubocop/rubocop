# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop suggests `ENV.fetch` for the replacement of `ENV[]`.
      # `ENV[]` silently fails and returns `nil` when the environment variable is unset,
      # which may cause unexpected behaviors when the developer forgets to set it.
      # On the other hand, `ENV.fetch` raises KeyError or returns the explicitly
      # specified default value.
      #
      # When an `ENV[]` is the LHS of `||`, the autocorrect makes the RHS
      # the default value of `ENV.fetch`.
      #
      # @example
      #   # bad
      #   ENV['X']
      #   ENV['X'] || 'string literal'
      #   ENV['X'] || some_method
      #   x = ENV['X']
      #
      #   ENV['X'] || y.map do |a|
      #     puts a * 2
      #   end
      #
      #   # good
      #   ENV.fetch('X')
      #   ENV.fetch('X', 'string literal')
      #   ENV.fetch('X') { some_method }
      #   x = ENV.fetch('X')
      #
      #   ENV.fetch('X') do
      #     y.map do |a|
      #       puts a * 2
      #     end
      #   end
      #
      #   # also good
      #   !ENV['X']
      #   ENV['X'].some_method # (e.g. `.nil?`)
      #
      class FetchEnvVar < Base
        extend AutoCorrector

        # rubocop:disable Layout/LineLength
        MSG_DEFAULT_NIL = 'Use `ENV.fetch(%<key>s)` or `ENV.fetch(%<key>s, nil)` instead of `ENV[%<key>s]`.'
        MSG_DEFAULT_RHS_SECOND_ARG_OF_FETCH = 'Use `ENV.fetch(%<key>s, %<default>s)` instead of `ENV[%<key>s] || %<default>s`.'
        MSG_DEFAULT_RHS_SINGLE_LINE_BLOCK = 'Use `ENV.fetch(%<key>s) { %<default>s }` instead of `ENV[%<key>s] || %<default>s`.'
        MSG_DEFAULT_RHS_MULTILINE_BLOCK = 'Use `ENV.fetch(%<key>s)` with a block containing `%<default>s ...`'
        # rubocop:enable Layout/LineLength

        # @!method env_with_bracket?(node)
        def_node_matcher :env_with_bracket?, <<~PATTERN
          (send (const nil? :ENV) :[] $_)
        PATTERN

        # @!method operand_of_or?(node)
        def_node_matcher :operand_of_or?, <<~PATTERN
          (^or ...)
        PATTERN

        # @!method block_control?(node)
        def_node_matcher :block_control?, <<~PATTERN
          ({next | break | retry | redo})
        PATTERN

        def on_send(node)
          env_with_bracket?(node) do |expression|
            break if allowed_var?(expression)
            break if allowable_use?(node)

            if operand_of_or?(node)
              target_node, target_expr = rightmost_offense_in_or_chains(node)

              if right_end_of_or_chains?(target_node) || rhs_cannot_be_default_value?(target_node)
                default_nil(target_node, target_expr)
              else
                default_rhs(target_node, target_expr)
              end
            else
              default_nil(node, expression)
            end
          end
        end

        private

        def allowed_var?(expression)
          expression.str_type? && cop_config['AllowedVars'].include?(expression.value)
        end

        def used_as_flag?(node)
          return false if node.root?

          node.parent.if_type? || (node.parent.send_type? && node.parent.prefix_bang?)
        end

        # Check if the node is a receiver and receives a message with dot syntax.
        def message_chained_with_dot?(node)
          return false if node.root?

          parent = node.parent
          return false if !parent.call_type? || parent.children.first != node

          parent.dot? || parent.safe_navigation?
        end

        # The following are allowed cases:
        #
        # - Used as a flag (e.g., `if ENV['X']` or `!ENV['X']`) because
        #   it simply checks whether the variable is set.
        # - Receiving a message with dot syntax, e.g. `ENV['X'].nil?`.
        # - `ENV['key']` assigned by logical AND/OR assignment.
        def allowable_use?(node)
          used_as_flag?(node) || message_chained_with_dot?(node) || assigned?(node)
        end

        # The following are allowed cases:
        #
        # - `ENV['key']` is a receiver of `||=`, e.g. `ENV['X'] ||= y`.
        # - `ENV['key']` is a receiver of `&&=`, e.g. `ENV['X'] &&= y`.
        def assigned?(node)
          return false unless (parent = node.parent)&.assignment?

          lhs, _method, _rhs = *parent
          node == lhs
        end

        def left_end_of_or_chains?(node)
          return false unless operand_of_or?(node)

          node.parent.lhs == node
        end

        def right_end_of_or_chains?(node)
          !(left_end_of_or_chains?(node) || node.parent&.parent&.or_type?)
        end

        # Returns the node and expression of the rightmost `ENV[]` in `||` chains.
        # e.g.,
        # `ENV['X'] || y || z || ENV['A'] || b`
        #                        ^^^^^^^^ Matches this one
        def rightmost_offense_in_or_chains(node)
          rmst_node = rmst_expr = nil
          or_nodes = [node.parent]

          while (grand_parent = or_nodes.last&.parent)&.or_type?
            or_nodes << grand_parent
          end

          # Finds the rightmost `ENV[]` in `||` chains and yields it.
          or_nodes.reverse.find do |or_node|
            env_with_bracket?(or_node.rhs) do |expression|
              rmst_node = or_node.rhs
              rmst_expr = expression
            end
          end
          return [rmst_node, rmst_expr] if rmst_node

          # Yields the node given to this method if no `ENV[]` is found in the above process.
          expression = env_with_bracket?(node)
          [node, expression]
        end

        def rhs_cannot_be_default_value?(node)
          rhs_is_block_control?(node)
        end

        def rhs_is_block_control?(node)
          rhs = left_end_of_or_chains?(node) ? node.parent.rhs : node.parent.parent.rhs
          block_control?(rhs)
        end

        def new_code_default_nil(expression)
          "ENV.fetch(#{expression.source}, nil)"
        end

        def new_code_default_rhs_single_line(node, expression)
          parent = node.parent
          if parent.rhs.basic_literal?
            "ENV.fetch(#{expression.source}, #{parent.rhs.source})"
          else
            "ENV.fetch(#{expression.source}) { #{parent.rhs.source} }"
          end
        end

        def new_code_default_rhs_multiline(node, expression)
          env_indent = indent(node.parent)
          default = node.parent.rhs.source.split("\n").map do |line|
            "#{env_indent}#{line}"
          end.join("\n")
          <<~NEW_CODE.chomp
            ENV.fetch(#{expression.source}) do
            #{configured_indentation}#{default}
            #{env_indent}end
          NEW_CODE
        end

        def new_code_default_rhs(node, expression)
          if node.parent.rhs.single_line?
            new_code_default_rhs_single_line(node, expression)
          else
            new_code_default_rhs_multiline(node, expression)
          end
        end

        def default_rhs(node, expression)
          if left_end_of_or_chains?(node)
            default_rhs_in_same_or(node, expression)
          else
            default_rhs_in_outer_or(node, expression)
          end
        end

        # Adds an offense and sets `nil` to the default value of `ENV.fetch`.
        # `ENV['X']` --> `ENV.fetch('X', nil)`
        def default_nil(node, expression)
          message = format(MSG_DEFAULT_NIL, key: expression.source)

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, new_code_default_nil(expression))
          end
        end

        # Adds an offense and makes the RHS the default value of `ENV.fetch`.
        # `ENV['X'] || y` --> `ENV.fetch('X') { y }`
        def default_rhs_in_same_or(node, expression)
          template = message_template_for(node.parent.rhs)
          message = format(template,
                           key: expression.source,
                           default: first_line_of(node.parent.rhs.source))

          add_offense(node, message: message) do |corrector|
            corrector.replace(node.parent, new_code_default_rhs(node, expression))
          end
        end

        # Adds an offense and makes the RHS the default value of `ENV.fetch`.
        # `z || ENV['X'] || y` --> `z || ENV.fetch('X') { y }`
        def default_rhs_in_outer_or(node, expression)
          parent = node.parent
          grand_parent = parent.parent

          template = message_template_for(grand_parent.rhs)
          message = format(template,
                           key: expression.source,
                           default: first_line_of(grand_parent.rhs.source))

          add_offense(node, message: message) do |corrector|
            lhs_code = parent.lhs.source
            rhs_code = new_code_default_rhs(parent, expression)
            corrector.replace(grand_parent, "#{lhs_code} || #{rhs_code}")
          end
        end

        def message_template_for(rhs)
          if rhs.multiline?
            MSG_DEFAULT_RHS_MULTILINE_BLOCK
          elsif rhs.basic_literal?
            MSG_DEFAULT_RHS_SECOND_ARG_OF_FETCH
          else
            MSG_DEFAULT_RHS_SINGLE_LINE_BLOCK
          end
        end

        def configured_indentation
          ' ' * (config.for_cop('Layout/IndentationWidth')['Width'] || 2)
        end

        def first_line_of(source)
          source.split("\n").first
        end
      end
    end
  end
end
