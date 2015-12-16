# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Helper module to provide common methods to classes needed for the
      # ConditionalAssignment Cop.
      module ConditionalAssignmentHelper
        def operator(node)
          node.send_type? ? node.loc.selector.source : node.loc.operator.source
        end

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
          when_branches.map do |branch|
            branch.children[1]
          end
        end

        def correct_branches(corrector, branches)
          branches.each do |branch|
            *_, assignment = *branch
            corrector.replace(branch.loc.expression,
                              assignment.loc.expression.source)
          end
        end

        def last_statement(branch)
          branch.begin_type? ? [*branch].last : branch
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

        MSG = 'Use the return of the conditional for variable assignment.'
        VARIABLE_ASSIGNMENT_TYPES =
          [:casgn, :cvasgn, :gvasgn, :ivasgn, :lvasgn].freeze
        ASSIGNMENT_TYPES =
          VARIABLE_ASSIGNMENT_TYPES + [:and_asgn, :or_asgn, :op_asgn].freeze
        IF = 'if'.freeze
        ELSIF = 'elsif'.freeze
        UNLESS = 'unless'.freeze
        LINE_LENGTH = 'Metrics/LineLength'.freeze
        ENABLED = 'Enabled'.freeze
        MAX = 'Max'.freeze
        CHECK_MULTIPLE_ASSIGNMENT =
          'CheckConditionsWithMultipleAssignments'.freeze

        def on_if(node) # rubocop:disable Metrics/MethodLength
          return if ternary_op?(node)
          return if elsif?(node)
          _condition, if_branch, else_branch = *node
          elsif_branches, else_branch = expand_elses(else_branch)
          # return if any branch is empty. An empty branch can be an `if`
          # without an `else`, or a branch that contains only comments.
          return if [if_branch, *elsif_branches, else_branch].any?(&:nil?)
          last_if_statement = last_statement(if_branch)

          elsifs_assignments = []
          last_elsifs_statements = []
          elsif_branches.each do |elsif_branch|
            elsifs_assignments << assignments(elsif_branch)
            last_elsifs_statements << last_statement(elsif_branch)
          end

          last_else_statement = last_statement(else_branch)
          last_statements = [last_if_statement, *last_elsifs_statements,
                             last_else_statement]

          return unless assignment_types_match?(*last_statements)
          return unless variables_match?(*last_statements)

          unless check_multiple_assignment
            if_assignments = assignments(if_branch)
            else_assignments = assignments(else_branch)

            if_variables = extract_variables(if_assignments)
            else_variables = extract_variables(else_assignments)
            elsif_variables = elsifs_assignments.map do |elsif_assignments|
              extract_variables(elsif_assignments)
            end

            return if multiple_assignments_spans_all_branches?(
              [if_variables, *elsif_variables, else_variables])
          end

          if_variable, = *last_if_statement
          return if correction_exceeds_line_limit?(node, if_variable,
                                                   operator(last_if_statement))

          add_offense(node, :expression)
        end

        def on_case(node) # rubocop:disable Metrics/MethodLength
          return unless node.loc.else
          _condition, *when_branches, else_branch = *node
          when_branches = expand_when_branches(when_branches)

          whens_assignments = []
          last_statement_in_whens = []
          when_branches.each do |when_branch|
            whens_assignments << assignments(when_branch)
            last_statement_in_whens << last_statement(when_branch)
          end

          last_else_statement = last_statement(else_branch)
          last_statements = [*last_statement_in_whens, last_else_statement]

          return unless assignment_types_match?(*last_statements)
          return unless variables_match?(*last_statements)

          unless check_multiple_assignment
            else_assignments = assignments(else_branch)
            else_variables = extract_variables(else_assignments)
            unless else_assignments.empty?
              when_variables = whens_assignments.map do |when_assignments|
                extract_variables(when_assignments)
              end

              return if multiple_assignments_spans_all_branches?(
                [*when_variables, else_variables])
            end
          end

          variable, = *last_else_statement
          operator = operator(last_else_statement)
          return if correction_exceeds_line_limit?(node, variable, operator)

          add_offense(node, :expression)
        end

        def autocorrect(node)
          case node.loc.keyword.source
          when IF
            IfCorrector.correct(node)
          when UNLESS
            UnlessCorrector.correct(node)
          else
            CaseCorrector.correct(node)
          end
        end

        private

        def assignments(branch)
          assignments = if branch.begin_type?
                          branch_nodes = *branch
                          branch_nodes.select do |n|
                            VARIABLE_ASSIGNMENT_TYPES.include?(n.type)
                          end
                        end
          assignments || []
        end

        def variables_match?(*branches)
          first_variable, = *branches.first
          branches.all? { |branch| branch.children[0] == first_variable }
        end

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
            _variable, method, = *branch
            return true if :<< == method
          end

          false
        end

        def extract_variables(assignments)
          assignments.map { |a| a.loc.name.source }
        end

        def multiple_assignments_spans_all_branches?(all_branch_variables)
          uniq_variables = all_branch_variables.flatten.uniq
          assignments_that_span_all_branches =
            uniq_variables.count do |variable|
              all_branch_variables.all? do |branch_variables|
                branch_variables.include?(variable)
              end
            end
          assignments_that_span_all_branches > 1
        end

        # If `Metrics/LineLength` is enabled, we do not want to introduce an
        # offense by auto-correcting this cop. Find the max configured line
        # length. Find the longest line of condition. Remove the assignment
        # from lines that contain the offending assignment because after
        # correcting, this will not be on the line anymore. Check if the length
        # of the longest line + the length of the corrected assignment is
        # greater than the max configured line length
        def correction_exceeds_line_limit?(node, variable, operator)
          return false unless config.for_cop(LINE_LENGTH)[ENABLED]
          assignment = "#{variable} #{operator} "
          assignment_regex = /#{variable}\s*#{operator}\s*/
          max_line_length = config.for_cop(LINE_LENGTH)[MAX]
          lines = node.loc.expression.source.lines.map do |line|
            line.chomp.sub(assignment_regex, '')
          end
          longest_line = lines.max_by(&:length)
          (longest_line + assignment).length > max_line_length
        end

        def check_multiple_assignment
          cop_config[CHECK_MULTIPLE_ASSIGNMENT]
        end
      end

      # Corrector to correct conditional assignment in `if` statements.
      class IfCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(node)
            _condition, if_branch, else_branch = *node
            if_branch = last_statement(if_branch)
            variable, *_operator, if_assignment = *if_branch

            # For send types, the variable will be `(send nil :var)`. Expanding
            # it will set `variable = nil` and `alternate = :var`.
            variable, alternate = *variable
            variable ||= alternate
            elsif_branches, else_branch = expand_elses(else_branch)
            elsif_branches.map! { |branch| last_statement(branch) }
            else_branch = last_statement(else_branch)
            _else_variable, *_operator, else_assignment = *else_branch

            lambda do |corrector|
              corrector.insert_before(node.loc.expression,
                                      "#{variable} #{operator(if_branch)} ")
              corrector.replace(if_branch.loc.expression,
                                if_assignment.loc.expression.source)
              correct_branches(corrector, elsif_branches)
              corrector.replace(else_branch.loc.expression,
                                else_assignment.loc.expression.source)
            end
          end
        end
      end

      # Corrector to correct conditional assignment in `case` statements.
      class CaseCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(node)
            _condition, *when_branches, else_branch = *node
            else_branch = last_statement(else_branch)
            when_branches = expand_when_branches(when_branches)
            when_branches.map! do |when_branch|
              last_statement(when_branch)
            end

            variable, *_operator, else_assignment = *else_branch
            # For send types, the variable will be `(send nil :var)`. Expanding
            # it will set `variable = nil` and `alternate = :var`.
            variable, alternate = *variable
            variable ||= alternate

            lambda do |corrector|
              corrector.insert_before(node.loc.expression,
                                      "#{variable} #{operator(else_branch)} ")
              correct_branches(corrector, when_branches)
              corrector.replace(else_branch.loc.expression,
                                else_assignment.loc.expression.source)
            end
          end
        end
      end

      # Corrector to correct conditional assignment in `unless` statements.
      class UnlessCorrector
        class << self
          include ConditionalAssignmentHelper

          def correct(node)
            _condition, else_branch, if_branch = *node
            if_branch = last_statement(if_branch)
            else_branch = last_statement(else_branch)
            variable, *_operator, if_assignment = *if_branch
            # For send types, the variable will be `(send nil :var)`. Expanding
            # it will set `variable = nil` and `alternate = :var`.
            variable, alternate = *variable
            variable ||= alternate
            _else_variable, *_operator, else_assignment = *else_branch

            lambda do |corrector|
              corrector.insert_before(node.loc.expression,
                                      "#{variable} #{operator(if_branch)} ")
              corrector.replace(if_branch.loc.expression,
                                if_assignment.loc.expression.source)
              corrector.replace(else_branch.loc.expression,
                                else_assignment.loc.expression.source)
            end
          end
        end
      end
    end
  end
end
