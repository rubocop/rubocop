# encoding: utf-8

module RuboCop
  module Cop
    module Style
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

        MSG = 'Use the return of the conditional for variable assignment.'
        ASSIGNMENT_TYPES = [:casgn, :cvasgn, :gvasgn, :ivasgn, :lvasgn,
                            :and_asgn, :or_asgn, :op_asgn].freeze
        IF = 'if'.freeze
        ELSIF = 'elsif'.freeze
        UNLESS = 'unless'.freeze
        LINE_LENGTH = 'Metrics/LineLength'.freeze
        ENABLED = 'Enabled'.freeze
        MAX = 'Max'.freeze

        def on_if(node)
          return if ternary_op?(node)
          return if elsif?(node)
          _condition, if_branch, else_branch = *node
          elsif_branches, else_branch = expand_elses(else_branch)
          # return if any branch is empty. An empty branch can be an `if`
          # without an `else`, or a branch that contains only comments.
          return if [if_branch, *elsif_branches, else_branch].any?(&:nil?)
          # Take the last line of the branch if the branch contains more than
          # one statement.
          *_, if_branch = *if_branch if if_branch.begin_type?
          return unless assignment_type?(if_branch)
          return unless types_match?(if_branch, *elsif_branches, else_branch)
          return unless variables_match?(if_branch, *elsif_branches,
                                         else_branch)
          if_variable, = *if_branch
          operator = operator(if_branch)
          return if correction_exceeds_line_limit?(node, if_variable, operator)

          add_offense(node, :expression)
        end

        def on_case(node)
          return unless node.loc.else
          _condition, *when_branches, else_branch = *node
          return unless else_branch # empty else
          # Take the last line of the branch if the branch contains more than
          # one statement.
          *_, else_branch = *else_branch if else_branch.begin_type?
          when_branches = expand_when_branches(when_branches)
          return unless assignment_type?(else_branch)
          return unless types_match?(*when_branches, else_branch)
          return unless variables_match?(*when_branches, else_branch)

          variable, = *else_branch
          operator = operator(else_branch)
          return if correction_exceeds_line_limit?(node, variable, operator)

          add_offense(node, :expression)
        end

        def autocorrect(node)
          case node.loc.keyword.source
          when IF
            if_correction(node)
          when UNLESS
            unless_correction(node)
          else
            case_correction(node)
          end
        end

        private

        # `elsif` branches show up in the `node` as an `else`. We need
        # to recursively iterate over all `else` branches and consider all
        # but the last `node` an `elsif` branch and consider the last `node`
        # the actual `else` branch.
        def expand_elses(branch)
          elsif_branches = expand_elsif(branch)
          else_branch = elsif_branches.any? ? elsif_branches.pop : branch
          if else_branch && else_branch.begin_type?
            *_, else_branch = *else_branch
          end
          [elsif_branches, else_branch]
        end

        def expand_elsif(node, elsif_branches = [])
          return [] if node.nil? || !node.if_type?
          _condition, elsif_branch, else_branch = *node
          if elsif_branch && elsif_branch.begin_type?
            *_, elsif_branch = *elsif_branch
          end
          elsif_branches << elsif_branch
          if else_branch && else_branch.if_type?
            expand_elsif(else_branch, elsif_branches)
          else
            elsif_branches << else_branch
          end
          elsif_branches
        end

        def variables_match?(*branches)
          first_variable, = *branches.first
          branches.all? { |branch| branch.children[0] == first_variable }
        end

        def types_match?(*nodes)
          return false unless nodes.all?

          first_type = nodes.first.type
          if first_type == :send
            first_method = nodes.first.method_name
            nodes.all? do |node|
              node.send_type? && node.method_name == first_method
            end
          else
            nodes.all? { |node| node.type == first_type }
          end
        end

        # The shovel operator `<<` does not have its own type. It is a `send`
        # type.
        def assignment_type?(branch)
          return true if ASSIGNMENT_TYPES.include?(branch.type)
          branch.send_type? && branch.method_name == :<<
        end

        # `when` nodes contain the entire branch including the condition.
        # We only need the contents of the branch, not the condition.
        def expand_when_branches(when_branches)
          when_branches.map do |branch|
            when_branch = branch.children[1]
            *_, when_branch = *when_branch if when_branch &&
                                              when_branch.begin_type?
            when_branch
          end
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

        def if_correction(node)
          _condition, if_branch, else_branch = *node
          *_, if_branch = *if_branch if if_branch.begin_type?
          variable, *_operator, if_assignment = *if_branch

          # For send types, the variable will be `(send nil :var)`. Expanding
          # it will set `variable = nil` and `alternate = :var`.
          variable, alternate = *variable
          variable ||= alternate
          elsif_branches, else_branch = expand_elses(else_branch)
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

        def case_correction(node)
          _condition, *when_branches, else_branch = *node
          *_, else_branch = *else_branch if else_branch.begin_type?
          when_branches = expand_when_branches(when_branches)

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

        def correct_branches(corrector, branches)
          branches.each do |branch|
            *_, assignment = *branch
            corrector.replace(branch.loc.expression,
                              assignment.loc.expression.source)
          end
        end

        def unless_correction(node)
          _condition, else_branch, if_branch = *node
          *_, if_branch = *if_branch if if_branch.begin_type?
          *_, else_branch = *else_branch if else_branch.begin_type?
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

        def operator(node)
          node.send_type? ? node.loc.selector.source : node.loc.operator.source
        end
      end
    end
  end
end
