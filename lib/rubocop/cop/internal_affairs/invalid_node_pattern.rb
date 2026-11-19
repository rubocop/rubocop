# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks node patterns for parts that can never match: node types that
      # do not exist, sequences with a number of children that a node of that
      # type never has, a node where a node of that type has a value like a
      # symbol (and the other way around), and predicates that nothing responds
      # to. Alternatives that are in a union more than once are reported too.
      #
      # Patterns that are built with interpolation are not checked.
      #
      # @example
      #   # bad
      #   def_node_matcher :my_matcher, <<~PATTERN
      #     (def _name _args)
      #   PATTERN
      #
      #   # good
      #   def_node_matcher :my_matcher, <<~PATTERN
      #     (def _name _args _body)
      #   PATTERN
      #
      #   # bad
      #   def_node_matcher :my_matcher, <<~PATTERN
      #     (send nil? "puts" ...)
      #   PATTERN
      #
      #   # good
      #   def_node_matcher :my_matcher, <<~PATTERN
      #     (send nil? :puts ...)
      #   PATTERN
      #
      #   # bad
      #   def_node_matcher :my_matcher, <<~PATTERN
      #     (send _ {:first :last :first})
      #   PATTERN
      #
      #   # good
      #   def_node_matcher :my_matcher, <<~PATTERN
      #     (send _ {:first :last})
      #   PATTERN
      #
      class InvalidNodePattern < Base
        RESTRICT_ON_SEND = %i[def_node_matcher def_node_search].freeze

        def on_send(node)
          pattern_node = node.arguments[1]
          return unless pattern_node&.any_str_type? && (start = pattern_start(pattern_node))

          problems(pattern_node).each do |problem|
            add_offense(offense_range(start, problem.range), message: problem.message)
          end
        end
        alias on_csend on_send

        private

        # @return [Parser::Source::Range, nil] where the pattern begins, if
        #   the positions in its value are the positions in the source
        def pattern_start(pattern_node)
          if pattern_node.heredoc?
            pattern_node.loc.heredoc_body unless pattern_node.each_child_node(:begin).any?
          elsif pattern_node.str_type? && pattern_node.loc?(:begin) && verbatim?(pattern_node)
            pattern_node.loc.begin.end
          end
        end

        def offense_range(start, range)
          begin_pos = start.begin_pos + range.begin_pos

          start.with(begin_pos: begin_pos, end_pos: begin_pos + range.size)
        end

        def verbatim?(pattern_node)
          pattern_node.source == "#{pattern_node.loc.begin.source}#{pattern_node.value}" \
                                 "#{pattern_node.loc.end.source}"
        end

        def problems(pattern_node)
          value = pattern_node.heredoc? ? pattern_node.loc.heredoc_body.source : pattern_node.value

          RuboCop::AST::NodePattern::Checker.new.check(value)
        rescue RuboCop::AST::NodePattern::Invalid
          []
        end
      end
    end
  end
end
