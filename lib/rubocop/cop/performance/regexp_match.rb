# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # In Ruby 2.4, `String#match?`, `Regexp#match?` and `Symbol#match?`
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
      #     if x.match(/re/)
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
      class RegexpMatch < Cop
        MSG =
          'Use `match?` instead of `%s` when `MatchData` is not used.'.freeze

        def_node_matcher :match_method?, <<-PATTERN
          {
            (send _recv :match _)
            (send _recv :match _ (:int ...))
          }
        PATTERN

        def_node_matcher :match_operator?, <<-PATTERN
          (send !nil :=~ !nil)
        PATTERN

        def_node_matcher :match_with_lvasgn?, <<-PATTERN
          (match_with_lvasgn !nil !nil)
        PATTERN

        MATCH_NODE_PATTERN = <<-PATTERN.freeze
          {
            #match_method?
            #match_operator?
            #match_with_lvasgn?
          }
        PATTERN

        def_node_matcher :match_node?, MATCH_NODE_PATTERN
        def_node_search :search_match_nodes, MATCH_NODE_PATTERN

        def_node_search :when_clauses, <<-PATTERN
          (when ...)
        PATTERN

        def_node_search :last_matches, <<-PATTERN
          {
            (send (const nil :Regexp) :last_match)
            (send (const nil :Regexp) :last_match _)
            ({back_ref nth_ref} _)
            (gvar #dollar_tilde)
          }
        PATTERN

        def on_if(node)
          return if target_ruby_version < 2.4

          cond, = *node
          check_condition(cond)
        end

        def on_case(node)
          return if target_ruby_version < 2.4

          case_cond, = *node
          return if case_cond
          when_clauses(node).each do |when_node|
            cond, = *when_node
            check_condition(cond)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if match_method?(node)
              corrector.replace(node.loc.selector, 'match?')
            elsif match_operator?(node)
              recv, _, arg = *node
              correct_operator(corrector, recv, arg)
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
            add_offense(cond, :expression,
                        format(MSG, cond.loc.selector.source))
          end
        end

        def last_match_used?(match_node)
          scope_root = scope_root(match_node)
          body = scope_root ? scope_body(scope_root) : match_node.ancestors.last
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
          node.children[2]
        end

        def scope_root(node)
          node.each_ancestor.find do |ancestor|
            ancestor.def_type? ||
              ancestor.class_type? ||
              ancestor.module_type?
          end
        end

        def dollar_tilde(sym)
          sym == :$~
        end

        def correct_operator(corrector, recv, arg)
          buffer = processed_source.buffer
          op_begin_pos = recv.loc.expression.end_pos
          op_end_pos = arg.loc.expression.begin_pos
          op_range = Parser::Source::Range.new(buffer, op_begin_pos, op_end_pos)
          corrector.replace(op_range, '.match?(')
          corrector.insert_after(arg.loc.expression, ')')
        end
      end
    end
  end
end
