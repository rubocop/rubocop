# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Prefer the use of uniq before pluck instead of after.
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
        MSG = 'Use uniq before pluck'.freeze
        DOT_UNIQ = '.uniq'.freeze
        NEWLINE = "\n".freeze

        def on_send(node)
          receiver, method_name, *_args = *node
          unless method_name == :uniq &&
                 !receiver.nil? &&
                 receiver.send_type? &&
                 receiver.children[1] == :pluck &&
                 !with_block?(node)
            return
          end

          add_offense(node, :selector, MSG)
        end

        def autocorrect(node)
          lines = node.source.split(NEWLINE)
          begin_remove_pos = if lines.last.strip == DOT_UNIQ
                               node.source.rindex(NEWLINE)
                             else
                               node.loc.dot.begin_pos
                             end
          receiver = node.children.first

          lambda do |corrector|
            corrector.remove(
              Parser::Source::Range.new(node.loc.expression.source_buffer,
                                        begin_remove_pos,
                                        node.loc.selector.end_pos)
            )
            corrector.insert_before(receiver.loc.dot.begin, DOT_UNIQ)
          end
        end

        private

        def with_block?(node)
          node.parent && node.parent.block_type?
        end
      end
    end
  end
end
