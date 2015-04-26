# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of `where.first` and
      # change them to use `find_by` instead.
      #
      # @example
      #   # bad
      #   User.where(name: 'Bruce').first
      #   User.where(name: 'Bruce').take
      #
      #   # good
      #   User.find_by(name: 'Bruce')
      class FindBy < Cop
        MSG = 'Use `find_by` instead of `where.%s`.'
        TARGET_SELECTORS = [:first, :take]

        def on_send(node)
          receiver, second_method, _selector = *node
          return unless TARGET_SELECTORS.include?(second_method)
          return if receiver.nil?
          _scope, first_method = *receiver
          return unless first_method == :where
          begin_of_offense = receiver.loc.selector.begin_pos
          end_of_offense = node.loc.selector.end_pos
          range = Parser::Source::Range.new(node.loc.expression.source_buffer,
                                            begin_of_offense,
                                            end_of_offense)

          add_offense(node, range, format(MSG, second_method))
        end

        def autocorrect(node)
          receiver, = *node
          where_loc = receiver.loc.selector
          first_loc = Parser::Source::Range.new(
            node.loc.expression.source_buffer,
            node.loc.dot.begin_pos,
            node.loc.selector.end_pos
          )

          lambda do |corrector|
            corrector.replace(where_loc, 'find_by')
            corrector.replace(first_loc, '')
          end
        end
      end
    end
  end
end
