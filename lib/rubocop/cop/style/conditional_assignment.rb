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

        IF = 'if'.freeze
        ELSIF = 'elsif'.freeze
        UNLESS = 'unless'.freeze
        LINE_LENGTH = 'Metrics/LineLength'.freeze
        INDENTATION_WIDTH = 'Style/IndentationWidth'.freeze
        ENABLED = 'Enabled'.freeze
        MAX = 'Max'.freeze
        WIDTH = 'Width'.freeze

        def on_if(node)
          return if ternary_op?(node)
          return if elsif?(node)

          _condition, if_branch, else_branch = *node
          branches = expand_elses(else_branch).unshift(if_branch)

          # return if any branch is empty. An empty branch can be an `if`
          # without an `else`, or a branch that contains only comments.
          return if branches.any?(&:nil?)

          check_node(node, branches)
        end

        def on_case(node)
          return unless node.loc.else
          _condition, *when_branches, else_branch = *node
          return unless else_branch # empty else

          when_branches = expand_when_branches(when_branches)

          check_node(node, when_branches.push(else_branch))
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

        def check_node(node, branches)
          return unless branches.all?

          # Take the last line of each branch if the branch contains more than
          # one statement.
          branches = branches.map { |branch| tail(branch) }

          return unless branches.all? { |branch| assignment_type?(branch) }
          return if branches.any?(&:masgn_type?)
          return unless lhs_all_match?(branches)
          return if correction_exceeds_line_limit?(node, branches)

          add_offense(node, :expression)
        end

        # `elsif` branches show up in the if node as nested `else` branches. We
        # need to recursively iterate over all `else` branches.
        def expand_elses(branch)
          if branch.nil?
            [nil]
          elsif branch.if_type?
            _condition, elsif_branch, else_branch = *branch
            expand_elses(else_branch).unshift(tail(elsif_branch))
          else
            [tail(branch)]
          end
        end

        def lhs_all_match?(branches)
          first_lhs = lhs(branches.first)
          branches.all? { |branch| lhs(branch) == first_lhs }
        end

        # The shovel operator `<<` does not have its own type. It is a `send`
        # type.
        def assignment_type?(branch)
          branch.assignment? || (branch.send_type? && branch.method_name == :<<)
        end

        # `when` nodes contain the entire branch including the condition.
        # We only need the contents of the branch, not the condition.
        def expand_when_branches(when_branches)
          when_branches.map { |branch| tail(branch.children[1]) }
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
          max_line_length   = config.for_cop(LINE_LENGTH)[MAX]
          indentation_width = config.for_cop(INDENTATION_WIDTH)[WIDTH] || 2
          lhs_length        = lhs(branches[0]).length
          right_hand_sides  = branches.map { |branch| branch.children.last }

          # first check the assignments at the end of each branch
          # (the lines which will be rewritten when autocorrecting)
          return true if longest_rhs(branches) + indentation_width +
                         lhs_length > max_line_length

          # then check all the others (which will not be rewritten)
          lines_with_numbers(node).any? do |str, lineno|
            next if right_hand_sides.any? { |val| val.loc.line == lineno }
            str.length + lhs_length > max_line_length
          end
        end

        def longest_rhs(branches)
          branches.map { |branch| branch.children.last.source.length }.max
        end

        def lines_with_numbers(node)
          line_nos = node.loc.line..node.loc.last_line
          node.source.lines.zip(line_nos)
        end

        def if_correction(node)
          _condition, if_branch, else_branch = *node
          if_branch = tail(if_branch)

          if_lhs, if_rhs = assignment(if_branch)
          else_branches = expand_elses(else_branch)

          lambda do |corrector|
            corrector.insert_before(node.loc.expression, if_lhs)
            corrector.replace(if_branch.loc.expression, if_rhs.source)
            correct_branches(corrector, else_branches)
          end
        end

        def case_correction(node)
          _condition, *when_branches, else_branch = *node
          else_branch   = tail(else_branch)
          when_branches = expand_when_branches(when_branches)

          lhs, rhs = assignment(else_branch)

          lambda do |corrector|
            corrector.insert_before(node.loc.expression, lhs)
            correct_branches(corrector, when_branches)
            corrector.replace(else_branch.loc.expression, rhs.source)
          end
        end

        def correct_branches(corrector, branches)
          branches.each do |branch|
            rhs = branch.children.last
            corrector.replace(branch.loc.expression, rhs.source)
          end
        end

        def unless_correction(node)
          _condition, else_branch, if_branch = *node
          if_branch   = tail(if_branch)
          else_branch = tail(else_branch)

          if_lhs, if_rhs = assignment(if_branch)
          _, else_rhs    = assignment(else_branch)

          lambda do |corrector|
            corrector.insert_before(node.loc.expression, if_lhs)
            corrector.replace(if_branch.loc.expression, if_rhs.source)
            corrector.replace(else_branch.loc.expression, else_rhs.source)
          end
        end

        def assignment(node)
          [lhs(node), node.children.last]
        end

        def lhs(node)
          if node.send_type?
            lhs_for_send(node)
          elsif node.op_asgn_type?
            "#{node.children[0].source} #{node.children[1]}= "
          elsif node.and_asgn_type?
            "#{node.children[0].source} &&= "
          elsif node.or_asgn_type?
            "#{node.children[0].source} ||= "
          else
            "#{node.children[0]} = "
          end
        end

        def lhs_for_send(node)
          receiver = node.receiver.nil? ? '' : node.receiver.source

          if node.method_name == :[]=
            indices = node.children[2...-1].map(&:source).join(', ')
            "#{receiver}[#{indices}] = "
          elsif node.method_name.to_s.end_with?('=')
            "#{receiver}.#{node.method_name.to_s[0...-1]} = "
          else
            "#{receiver} #{node.method_name} "
          end
        end

        def tail(node)
          if node && node.begin_type?
            node.children.last
          else
            node
          end
        end
      end
    end
  end
end
