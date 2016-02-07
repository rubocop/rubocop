# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Helper module to provide common methods to classes needed for the
      # ConditionalAssignment Cop.
      module ConditionalAssignmentHelper
        EQUAL = '='.freeze
        END_ALIGNMENT = 'Lint/EndAlignment'.freeze
        ALIGN_WITH = 'AlignWith'.freeze
        KEYWORD = 'keyword'.freeze

        # `elsif` branches show up in the `node` as an `else`. We need
        # to recursively iterate over all `else` branches and consider all
        # but the last `node` an `elsif` branch and consider the last `node`
        # the actual `else` branch.
        def expand_elses(branch)
          elsif_branches = expand_elsif(branch)
          else_branch = elsif_branches.any? ? elsif_branches.pop : branch
          [elsif_branches, else_branch]
        end

        # `when` nodes contain the entire branch including the condition.
        # We only need the contents of the branch, not the condition.
        def expand_when_branches(when_branches)
          when_branches.map { |branch| branch.children[1] }
        end

        def correct_branches(corrector, branches)
          branches.each do |branch|
            *_, assignment = *branch
            corrector.replace(branch.source_range, assignment.source)
          end
        end

        def tail(branch)
          branch.begin_type? ? [*branch].last : branch
        end

        def lhs(node)
          case node.type
          when :send
            lhs_for_send(node)
          when :op_asgn
            "#{node.children[0].source} #{node.children[1]}= "
          when :and_asgn
            "#{node.children[0].source} &&= "
          when :or_asgn
            "#{node.children[0].source} ||= "
          when :casgn
            "#{node.children[1]} = "
          when *ConditionalAssignment::VARIABLE_ASSIGNMENT_TYPES
            "#{node.children[0]} = "
          else
            node.source
          end
        end

        def indent(cop, source)
          if cop.config[END_ALIGNMENT] &&
             cop.config[END_ALIGNMENT][ALIGN_WITH] &&
             cop.config[END_ALIGNMENT][ALIGN_WITH] == KEYWORD
            ' ' * source.length
          else
            ''
          end
        end

        private

        def expand_elsif(node, elsif_branches = [])
          return [] if node.nil? || !node.if_type?
          _condition, elsif_branch, else_branch = *node
          elsif_branches << elsif_branch
          if else_branch && else_branch.if_type?
            expand_elsif(else_branch, elsif_branches)
          else
            elsif_branches << else_branch
          end
          elsif_branches
        end

        def lhs_for_send(node)
          receiver = node.receiver.nil? ? '' : node.receiver.source

          if node.method_name == :[]=
            indices = node.children[2...-1].map(&:source).join(', ')
            "#{receiver}[#{indices}] = "
          elsif node.method_name.to_s.end_with?(EQUAL) &&
                ![:!=, :==].include?(node.method_name)
            "#{receiver}.#{node.method_name[0...-1]} = "
          else
            "#{receiver} #{node.method_name} "
          end
        end
      end

      # Check for `if` and `case` statements where each branch is used for
      # assignment to the same variable when using the return of the
      # condition can be used instead.
      #
      # @example
      #   # bad
      #   if foo
      #     bar = 1
      #   else
      #     bar = 2
      #   end
      #
      #   case foo
      #   when 'a'
      #     bar += 1
      #   else
      #     bar += 2
      #   end
      #
      #   if foo
      #     some_method
      #     bar = 1
      #   else
      #     some_other_method
      #     bar = 2
      #   end
      #
      #   # good
      #   bar = if foo
      #           1
      #         else
      #           2
      #         end
      #
      #   bar += case foo
      #          when 'a'
      #            1
      #          else
      #            2
      #          end
      #
      #   bar << if foo
      #            some_method
      #            1
      #          else
      #            some_other_method
      #            2
      #          end
      class ConditionalAssignment < Cop
        include IfNode
        include ConditionalAssignmentHelper

        MSG = 'Use the return of the conditional for variable assignment ' \
              'and comparison.'.freeze
        VARIABLE_ASSIGNMENT_TYPES =
          [:casgn, :cvasgn, :gvasgn, :ivasgn, :lvasgn].freeze
        ASSIGNMENT_TYPES =
          VARIABLE_ASSIGNMENT_TYPES + [:and_asgn, :or_asgn, :op_asgn].freeze
        IF = 'if'.freeze
        UNLESS = 'unless'.freeze
        LINE_LENGTH = 'Metrics/LineLength'.freeze
        INDENTATION_WIDTH = 'Style/IndentationWidth'.freeze
        ENABLED = 'Enabled'.freeze
        MAX = 'Max'.freeze
        SINGLE_LINE_CONDITIONS_ONLY = 'SingleLineConditionsOnly'.freeze
        WIDTH = 'Width'.freeze
        METHODS = [:[]=, :<<, :=~, :!~, :<=>].freeze

        def lhs_all_match?(branches)
          first_lhs = lhs(branches.first)
          branches.all? { |branch| lhs(branch) == first_lhs }
        end

        def on_if(node)
          return if elsif?(node)

          _condition, if_branch, else_branch = *node
          elsif_branches, else_branch = expand_elses(else_branch)
          return unless else_branch # empty else

          branches = [if_branch, *elsif_branches, else_branch]

          check_node(node, branches)
        end

        def on_case(node)
          _condition, *when_branches, else_branch = *node
          return unless else_branch # empty else

          when_branches = expand_when_branches(when_branches)
          branches = [*when_branches, else_branch]

          check_node(node, branches)
        end

        def autocorrect(node)
          if ternary_op?(node)
            TernaryCorrector.correct(node)
          else
            case node.loc.keyword.source
            when IF
              IfCorrector.correct(self, node)
            when UNLESS
              UnlessCorrector.correct(self, node)
            else
              CaseCorrector.correct(self, node)
            end
          end
        end

        private

        def assignment_types_match?(*nodes)
          return unless assignment_type?(nodes.first)
          first_type = nodes.first.type
          nodes.all? { |node| node.type == first_type }
        end

        # The shovel operator `<<` does not have its own type. It is a `send`
        # type.
        def assignment_type?(branch)
          return true if ASSIGNMENT_TYPES.include?(branch.type)

          if branch.send_type?
            _receiver, method, = *branch
            return true if METHODS.include?(method)
            return true if method.to_s.end_with?(EQUAL)
          end

          false
        end

        def check_node(node, branches)
          return unless branches.all?
          last_statements = branches.map { |branch| tail(branch) }
          return unless lhs_all_match?(last_statements)
          return if last_statements.any?(&:masgn_type?)
          return unless assignment_types_match?(*last_statements)

          return if single_line_conditions_only? && branches.any?(&:begin_type?)
          return if correction_exceeds_line_limit?(node, branches)

          add_offense(node, :expression)
        end

        # If `Metrics/LineLength` is enabled, we do not want to introduce an
        # offense by auto-correcting this cop. Find the max configured line
        # length. Find the longest line of condition. Remove the assignment
        # from lines that contain the offending assignment because after
        # correcting, this will not be on the line anymore. Check if the length
        # of the longest line + the length of the corrected assignment is
        # greater than the max configured line length
        def correction_exceeds_line_limit?(node, branches)
          return false unless config.for_cop(LINE_LENGTH)[ENABLED]
          assignment = lhs(tail(branches[0]))
          assignment_regex = /#{assignment.gsub(' ', '\s*')}/
          max_line_length = config.for_cop(LINE_LENGTH)[MAX]
          indentation_width = config.for_cop(INDENTATION_WIDTH)[WIDTH] || 2
          return true if longest_rhs(branches) + indentation_width +
                         assignment.length > max_line_length
          lines = node.source.lines.map do |line|
            line.chomp.sub(assignment_regex, '')
          end
          longest_line = lines.max_by(&:length)
          (longest_line + assignment).length > max_line_length
        end

        def longest_rhs(branches)
          branches.map { |branch| branch.children.last.source.length }.max
        end

        def lines_with_numbers(node)
          line_nos = node.loc.line..node.loc.last_line
          node.source.lines.zip(line_nos)
        end

        def single_line_conditions_only?
          cop_config[SINGLE_LINE_CONDITIONS_ONLY]
        end
      end

      # Corrector to correct conditional assignment in ternary conditions.
      class TernaryCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(node)
            condition, if_branch, else_branch = *node
            _variable, *_operator, if_rhs = *if_branch
            _else_variable, *_operator, else_rhs = *else_branch
            condition = condition.source
            if_rhs = if_rhs.source
            else_rhs = else_rhs.source

            ternary = "#{condition} ? #{if_rhs} : #{else_rhs}"
            if if_branch.send_type? && if_branch.method_name != :[]=
              ternary = "(#{ternary})"
            end
            correction = "#{lhs(if_branch)}#{ternary}"

            lambda do |corrector|
              corrector.replace(node.source_range, correction)
            end
          end
        end
      end

      # Corrector to correct conditional assignment in `if` statements.
      class IfCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(cop, node)
            _condition, if_branch, else_branch = *node
            if_branch = tail(if_branch)
            _variable, *_operator, if_assignment = *if_branch
            elsif_branches, else_branch = expand_elses(else_branch)
            elsif_branches.map! { |branch| tail(branch) }
            else_branch = tail(else_branch)
            _else_variable, *_operator, else_assignment = *else_branch

            lambda do |corrector|
              corrector.insert_before(node.source_range, lhs(if_branch))
              corrector.replace(if_branch.source_range, if_assignment.source)
              correct_branches(corrector, elsif_branches)
              corrector.replace(else_branch.source_range,
                                else_assignment.source)
              corrector.insert_before(node.loc.end, indent(cop, lhs(if_branch)))
            end
          end
        end
      end

      # Corrector to correct conditional assignment in `case` statements.
      class CaseCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(cop, node)
            _condition, *when_branches, else_branch = *node
            else_branch = tail(else_branch)
            when_branches = expand_when_branches(when_branches)
            when_branches.map! { |when_branch| tail(when_branch) }
            _variable, *_operator, else_assignment = *else_branch

            lambda do |corrector|
              corrector.insert_before(node.source_range, lhs(else_branch))
              correct_branches(corrector, when_branches)
              corrector.replace(else_branch.source_range,
                                else_assignment.source)

              corrector.insert_before(node.loc.end,
                                      indent(cop, lhs(else_branch)))
            end
          end
        end
      end

      # Corrector to correct conditional assignment in `unless` statements.
      class UnlessCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(cop, node)
            _condition, else_branch, if_branch = *node
            if_branch = tail(if_branch)
            else_branch = tail(else_branch)
            _variable, *_operator, if_assignment = *if_branch
            _else_variable, *_operator, else_assignment = *else_branch

            lambda do |corrector|
              corrector.insert_before(node.source_range, lhs(if_branch))
              corrector.replace(if_branch.source_range, if_assignment.source)
              corrector.replace(else_branch.source_range,
                                else_assignment.source)
              corrector.insert_before(node.loc.end, indent(cop, lhs(if_branch)))
            end
          end
        end
      end
    end
  end
end
