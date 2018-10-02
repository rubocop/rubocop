# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # In Ruby 2.4, `String#match?`, `Regexp#match?`, and `Symbol#match?`
      # have been added. The methods are faster than `match`.
      # Because the methods avoid creating a `MatchData` object or saving
      # backref.
      # So, when `MatchData` is not used, use `match?` instead of `match`.
      #
      # @example
      #   # bad
      #   def foo
      #     if x =~ /re/
      #       do_something
      #     end
      #   end
      #
      #   # bad
      #   def foo
      #     if x !~ /re/
      #       do_something
      #     end
      #   end
      #
      #   # bad
      #   def foo
      #     if x.match(/re/)
      #       do_something
      #     end
      #   end
      #
      #   # bad
      #   def foo
      #     if /re/ === x
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     if x.match?(/re/)
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     if !x.match?(/re/)
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     if x =~ /re/
      #       do_something(Regexp.last_match)
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     if x.match(/re/)
      #       do_something($~)
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     if /re/ === x
      #       do_something($~)
      #     end
      #   end
      class RegexpMatch < Cop
        extend TargetRubyVersion

        minimum_target_ruby_version 2.4

        # Constants are included in this list because it is unlikely that
        # someone will store `nil` as a constant and then use it for comparison
        TYPES_IMPLEMENTING_MATCH = %i[const regexp str sym].freeze
        MSG =
          'Use `match?` instead of `%<current>s` when `MatchData` ' \
          'is not used.'.freeze

        def_node_matcher :match_method?, <<-PATTERN
          {
            (send _recv :match _)
            (send _recv :match _ (int ...))
          }
        PATTERN

        def_node_matcher :match_operator?, <<-PATTERN
          (send !nil? {:=~ :!~} !nil?)
        PATTERN

        def_node_matcher :match_threequals?, <<-PATTERN
          (send (regexp (str _) {(regopt) (regopt _)}) :=== !nil?)
        PATTERN

        def match_with_lvasgn?(node)
          return false unless node.match_with_lvasgn_type?

          regexp, _rhs = *node
          regexp.to_regexp.named_captures.empty?
        end

        MATCH_NODE_PATTERN = <<-PATTERN.freeze
          {
            #match_method?
            #match_operator?
            #match_threequals?
            #match_with_lvasgn?
          }
        PATTERN

        def_node_matcher :match_node?, MATCH_NODE_PATTERN
        def_node_search :search_match_nodes, MATCH_NODE_PATTERN

        def_node_search :last_matches, <<-PATTERN
          {
            (send (const nil? :Regexp) :last_match)
            (send (const nil? :Regexp) :last_match _)
            ({back_ref nth_ref} _)
            (gvar #match_gvar?)
          }
        PATTERN

        def on_if(node)
          check_condition(node.condition)
        end

        def on_case(node)
          return if node.condition

          node.each_when do |when_node|
            when_node.each_condition do |condition|
              check_condition(condition)
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if match_method?(node)
              corrector.replace(node.loc.selector, 'match?')
            elsif match_operator?(node) || match_threequals?(node)
              recv, oper, arg = *node
              correct_operator(corrector, recv, arg, oper)
            elsif match_with_lvasgn?(node)
              recv, arg = *node
              correct_operator(corrector, recv, arg)
            end
          end
        end

        private

        def check_condition(cond)
          match_node?(cond) do
            return if last_match_used?(cond)

            add_offense(cond)
          end
        end

        def message(node)
          format(MSG, current: node.loc.selector.source)
        end

        def last_match_used?(match_node)
          scope_root = scope_root(match_node)
          body = scope_root ? scope_body(scope_root) : match_node.ancestors.last

          return true if match_node.parent.if_type? &&
                         match_node.parent.modifier_form?

          match_node_pos = match_node.loc.expression.begin_pos

          next_match_pos = next_match_pos(body, match_node_pos, scope_root)
          range = match_node_pos..next_match_pos

          find_last_match(body, range, scope_root)
        end

        def next_match_pos(body, match_node_pos, scope_root)
          node = search_match_nodes(body).find do |match|
            match.loc.expression.begin_pos > match_node_pos &&
              scope_root(match) == scope_root
          end
          node ? node.loc.expression.begin_pos : Float::INFINITY
        end

        def find_last_match(body, range, scope_root)
          last_matches(body).find do |ref|
            ref_pos = ref.loc.expression.begin_pos
            range.cover?(ref_pos) &&
              scope_root(ref) == scope_root
          end
        end

        def scope_body(node)
          children = node.children
          case node.type
          when :module
            children[1]
          when :defs
            children[3]
          else
            children[2]
          end
        end

        def scope_root(node)
          node.each_ancestor.find do |ancestor|
            ancestor.def_type? ||
              ancestor.defs_type? ||
              ancestor.class_type? ||
              ancestor.module_type?
          end
        end

        def match_gvar?(sym)
          %i[
            $~
            $MATCH
            $PREMATCH
            $POSTMATCH
            $LAST_PAREN_MATCH
            $LAST_MATCH_INFO
          ].include?(sym)
        end

        def correct_operator(corrector, recv, arg, oper = nil)
          op_range = correction_range(recv, arg)

          if TYPES_IMPLEMENTING_MATCH.include?(recv.type)
            corrector.replace(op_range, '.match?(')
          elsif TYPES_IMPLEMENTING_MATCH.include?(arg.type)
            corrector.replace(op_range, '.match?(')
            swap_receiver_and_arg(corrector, recv, arg)
          else
            corrector.replace(op_range, '&.match?(')
          end

          corrector.insert_after(arg.loc.expression, ')')
          corrector.insert_before(recv.loc.expression, '!') if oper == :!~
        end

        def swap_receiver_and_arg(corrector, recv, arg)
          corrector.replace(recv.loc.expression, arg.source)
          corrector.replace(arg.loc.expression, recv.source)
        end

        def correction_range(recv, arg)
          buffer = processed_source.buffer
          op_begin_pos = recv.loc.expression.end_pos
          op_end_pos = arg.loc.expression.begin_pos
          Parser::Source::Range.new(buffer, op_begin_pos, op_end_pos)
        end
      end
    end
  end
end
