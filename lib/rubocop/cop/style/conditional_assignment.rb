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

        def on_if(node)
          return if ternary_op?(node)
          return if elsif?(node)
          _condition, if_branch, else_branch = *node
          elsif_branches, else_branch = expand_elses(else_branch)
          return if [if_branch, *elsif_branches, else_branch].any?(&:nil?)
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
          first_type = nodes.first.type
          nodes.all? { |node| node.type == first_type }
        end

        def assignment_type?(branch)
          return true if ASSIGNMENT_TYPES.include?(branch.type)

          if branch.send_type?
            _variable, method, = *branch
            return true if method == :<<
          end

          false
        end

        def expand_when_branches(when_branches)
          when_branches.map do |branch|
            when_branch = branch.children[1]
            *_, when_branch = *when_branch if when_branch.begin_type?
            when_branch
          end
        end

        def correction_exceeds_line_limit?(node, variable, operator)
          return false unless config.for_cop('Metrics/LineLength')['Enabled']
          assignment = "#{variable} #{operator} "
          assignment_regex = /#{variable}\s*#{operator}\s*/
          max_line_length = config.for_cop('Metrics/LineLength')['Max']
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
