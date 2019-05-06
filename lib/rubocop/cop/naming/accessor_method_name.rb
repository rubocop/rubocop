# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that accessor methods are named properly.
      #
      # @example
      #   # bad
      #   def set_attribute(value)
      #   end
      #
      #   # good
      #   def attribute=(value)
      #   end
      #
      #   # bad
      #   def get_attribute
      #   end
      #
      #   # good
      #   def attribute
      #   end
      class AccessorMethodName < Cop
        MSG_READER = 'Do not prefix reader method names with `get_`.'
        MSG_WRITER = 'Do not prefix writer method names with `set_`.'

        def on_def(node)
          return unless bad_reader_name?(node) || bad_writer_name?(node)

          add_offense(node, location: :name)
        end
        alias on_defs on_def

        private

        def message(node)
          if bad_reader_name?(node)
            MSG_READER
          elsif bad_writer_name?(node)
            MSG_WRITER
          end
        end

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
