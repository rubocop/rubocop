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

          source_buffer = node.loc.expression.source_buffer
          location_of_select = receiver.loc.selector.begin_pos
          end_location = node.loc.selector.end_pos

          range = Parser::Source::Range.new(source_buffer,
                                            location_of_select,
                                            end_location)

          add_offense(node, range, format(MSG,
                                          preferred_method,
                                          first_method))
        end

        def autocorrect(node)
          receiver, _first_method = *node

          first_range = Parser::Source::Range.new(
            node.loc.expression.source_buffer,
            node.loc.dot.begin_pos,
            node.loc.selector.end_pos)

          receiver, _args, _body = *receiver if receiver.block_type?

          select_range = Parser::Source::Range.new(
            node.loc.expression.source_buffer,
            receiver.loc.selector.begin_pos,
            receiver.loc.selector.end_pos)

          @corrections << lambda do |corrector|
            corrector.remove(first_range)
            corrector.replace(select_range, preferred_method)
          end
        end

        private

        def preferred_method
          cop_config['PreferredMethod'] || default_cop_config['PreferredMethod']
        end

        def default_cop_config
          ConfigLoader.default_configuration[cop_name]
        end
      end
    end
  end
end
