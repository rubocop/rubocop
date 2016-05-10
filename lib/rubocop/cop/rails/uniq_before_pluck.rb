# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Prefer the use of uniq/distinct before pluck instead of after.
      #
      # The use of uniq before pluck is preferred because it executes
      # within the database.
      #
      # @example
      #   # bad
      #   Model.where(...).pluck(:id).uniq
      #
      #   # good
      #   Model.where(...).uniq.pluck(:id)
      #
      class UniqBeforePluck < RuboCop::Cop::Cop
        MSG = 'Use %s before pluck'.freeze
        NEWLINE = "\n".freeze

        def on_send(node)
          receiver, method_name, *_args = *node

          unless [:distinct, :uniq].include?(method_name) &&
                 !receiver.nil? &&
                 receiver.send_type? &&
                 receiver.children[1] == :pluck
            return
          end
          add_offense(node, :selector, MSG % method_name)
        end

        def autocorrect(node)
          method_name = '.' + node.loc.selector.source
          receiver = node.children.first

          lambda do |corrector|
            corrector.remove(
              Parser::Source::Range.new(node.loc.expression.source_buffer,
                                        begin_remove_pos(node, method_name),
                                        node.loc.selector.end_pos)
            )
            corrector.insert_before(receiver.loc.dot.begin, method_name)
          end
        end

        private

        def begin_remove_pos(node, method_name)
          lines = node.source.split(NEWLINE)

          if lines.last.strip == method_name
            node.source.rindex(NEWLINE)
          else
            node.loc.dot.begin_pos
          end
        end
      end
    end
  end
end
