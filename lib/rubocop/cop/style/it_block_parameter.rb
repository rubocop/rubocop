# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for blocks with one argument where `it` block parameter can be used.
      #
      # It provides four `EnforcedStyle` options:
      #
      # 1. `allow_single_line` (default) ... Always uses the `it` block parameter in a single line.
      # 2. `only_numbered_parameters` ... Detects only numbered block parameters.
      # 3. `always` ... Always uses the `it` block parameter.
      # 4. `disallow` ... Disallows the `it` block parameter.
      #
      # A single numbered parameter is detected when `allow_single_line`,
      # `only_numbered_parameters`, or `always`.
      #
      # @example EnforcedStyle: allow_single_line (default)
      #   # bad
      #   block do
      #     do_something(it)
      #   end
      #   block { do_something(_1) }
      #
      #   # good
      #   block { do_something(it) }
      #   block { |named_param| do_something(named_param) }
      #
      # @example EnforcedStyle: only_numbered_parameters
      #   # bad
      #   block { do_something(_1) }
      #
      #   # good
      #   block { do_something(it) }
      #   block { |named_param| do_something(named_param) }
      #
      # @example EnforcedStyle: always
      #   # bad
      #   block { do_something(_1) }
      #   block { |named_param| do_something(named_param) }
      #
      #   # good
      #   block { do_something(it) }
      #
      # @example EnforcedStyle: disallow
      #   # bad
      #   block { do_something(it) }
      #
      #   # good
      #   block { do_something(_1) }
      #   block { |named_param| do_something(named_param) }
      #
      class ItBlockParameter < Base
        include ConfigurableEnforcedStyle
        extend TargetRubyVersion
        extend AutoCorrector

        MSG_USE_IT_PARAMETER = 'Use `it` block parameter.'
        MSG_AVOID_IT_PARAMETER = 'Avoid using `it` block parameter.'
        MSG_AVOID_IT_PARAMETER_MULTILINE = 'Avoid using `it` block parameter for multi-line blocks.'

        SCOPE_TYPES = %i[any_def class module sclass].freeze

        minimum_target_ruby_version 3.4

        # `Style/StabbyLambdaParentheses` wraps the parameter this cop removes in the same pass,
        # which would leave an empty parameter list that forbids `it`.
        def self.autocorrect_incompatible_with
          [Style::Lambda, Style::StabbyLambdaParentheses]
        end

        def on_new_investigation
          @it_variable_definitions = nil
        end

        def on_block(node)
          return unless style == :always
          return unless node.arguments.one?

          # `restarg`, `kwrestarg`, `blockarg` nodes can return early.
          return unless node.first_argument.arg_type?

          block_argument_name = node.first_argument.source
          return if keep_parameter_name?(node.body, block_argument_name)

          find_block_variables(node, block_argument_name).each do |variable|
            add_offense(variable, message: MSG_USE_IT_PARAMETER) do |corrector|
              corrector.remove(node.arguments)
              corrector.replace(variable, 'it')
            end
          end
        end

        def on_numblock(node)
          return if style == :disallow
          return unless node.children[1] == 1

          variables = find_block_variables(node, '_1')

          variables.each do |variable|
            add_offense(variable, message: MSG_USE_IT_PARAMETER) do |corrector|
              corrector.replace(variable, 'it')
            end
          end
        end

        def on_itblock(node)
          case style
          when :allow_single_line
            return if node.single_line?

            add_offense(node, message: MSG_AVOID_IT_PARAMETER_MULTILINE)
          when :disallow
            variables = find_block_variables(node, 'it')

            variables.each do |variable|
              add_offense(variable, message: MSG_AVOID_IT_PARAMETER)
            end
          end
        end

        private

        def find_block_variables(node, block_argument_name)
          return [] if !node.body || it_variable_in_scope?(node)

          ranges = inner_block_ranges(node.body)

          block_variables(node.body, block_argument_name).reject do |variable|
            ranges.any? { |range| range.contains?(variable.source_range) }
          end
        end

        def it_variable_in_scope?(node)
          scope = nearest_scope(node)
          return true if it_argument_in_scope?(node, scope)

          it_variable_definitions.any? do |definition|
            nearest_scope(definition).equal?(scope) && visible_in_block?(definition, node)
          end
        end

        def it_variable_definitions
          @it_variable_definitions ||=
            variable_definitions(processed_source.ast).filter_map do |name, definition|
              definition if name == 'it'
            end
        end

        def nearest_scope(node)
          node.each_ancestor(*SCOPE_TYPES).first
        end

        def it_argument_in_scope?(node, scope)
          owners = node.each_ancestor(:block).select { |block| nearest_scope(block).equal?(scope) }
          owners << scope if scope&.any_def_type?

          owners.any? { |owner| owner.arguments.argument_list.any? { |arg| arg.name == :it } }
        end

        def visible_in_block?(definition, node)
          return true if definition.source_range.begin_pos < node.source_range.begin_pos

          node.source_range.contains?(definition.source_range)
        end

        def inner_block_ranges(body)
          body.each_node(:any_block).map { |block| block.loc.begin.join(block.loc.end) }
        end

        def keep_parameter_name?(body, block_arg_name)
          used_within_inner_block?(body, block_arg_name) || reassigned?(body, block_arg_name)
        end

        def used_within_inner_block?(body, block_argument_name)
          return false unless body

          ranges = inner_block_ranges(body)

          block_variables(body, block_argument_name).any? do |variable|
            ranges.any? { |range| range.contains?(variable.source_range) }
          end
        end

        def reassigned?(body, block_argument_name)
          return false unless body

          variable_definitions(body).any? { |name, _definition| name == block_argument_name }
        end

        def block_variables(body, block_argument_name)
          body.each_descendant(:lvar).select do |descendant|
            descendant.source == block_argument_name
          end
        end

        def variable_definitions(node)
          node.each_node(:lvasgn, :match_var, :match_with_lvasgn).flat_map do |definition|
            names = if definition.match_with_lvasgn_type?
                      definition.children.first.each_capture(named: true).map(&:name)
                    else
                      [definition.children.first.to_s]
                    end

            names.map { |name| [name, definition] }
          end
        end
      end
    end
  end
end
