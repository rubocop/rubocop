# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `select.first` or
      # `find_all.first` and change them to use `detect` instead.
      #
      # @example
      #   # bad
      #   [].select { |item| true }.first
      #   [].find_all { |item| true }.first
      #
      #   # good
      #   [].detect { |item| true }
      class Detect < Cop
        MSG = 'Use `%s` instead of `%s.first`.'

        SELECT_METHODS = [:select, :find_all]

        def on_send(node)
          receiver, second_method = *node
          return unless second_method == :first
          return if receiver.nil?

          receiver, _args, _body = *receiver if receiver.block_type?

          _, first_method = *receiver
          return unless SELECT_METHODS.include?(first_method)

          range = receiver.loc.selector.join(node.loc.selector)

          add_offense(node, range, format(MSG,
                                          preferred_method,
                                          first_method))
        end

        def autocorrect(node)
          receiver, _first_method = *node

          first_range = node.loc.dot.join(node.loc.selector)

          receiver, _args, _body = *receiver if receiver.block_type?

          @corrections << lambda do |corrector|
            corrector.remove(first_range)
            corrector.replace(receiver.loc.selector, preferred_method)
          end
        end

        private

        def preferred_method
          cop_config['PreferredMethod']
        end
      end
    end
  end
end
