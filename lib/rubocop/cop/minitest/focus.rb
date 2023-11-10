# frozen_string_literal: true

module RuboCop::Cop::Minitest
  class NoFocus < RuboCop::Cop::Cop
    MSG = 'Remove `focus` from tests.'

    def_node_matcher :focused?, <<-MATCHER
      (send nil? :focus)
    MATCHER

    def on_send(node)
      return unless focused?(node)

      add_offense node
    end
  end
end
