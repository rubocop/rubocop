# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that accessor methods are named properly.
      #
      # @example
      #   # bad
      #   def set_attribute(value) ...
      #
      #   # good
      #   def attribute=(value)
      #
      #   # bad
      #   def get_attribute ...
      #
      #   # good
      #   def attribute ...
      class AccessorMethodName < Cop
        def on_def(node)
          msg =
            if bad_reader_name?(node)
              'Do not prefix reader method names with `get_`.'
            elsif bad_writer_name?(node)
              'Do not prefix writer method names with `set_`.'
            end

          add_offense(node, location: :name, message: msg) if msg
        end
        alias on_defs on_def

        private

        def bad_reader_name?(node)
          node.method_name.to_s.start_with?('get_') && !node.arguments?
        end

        def bad_writer_name?(node)
          node.method_name.to_s.start_with?('set_') && node.arguments.one?
        end
      end
    end
  end
end
