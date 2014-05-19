# encoding: utf-8

module Rubocop
  module Cop
    module Style
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
        include CheckMethods
        MSG_GET = 'Do not prefix reader method names with `get_`.'
        MSG_SET = 'Do not prefix writer method names with `set_`.'
        private_constant :MSG_GET, :MSG_SET

        private

        def check(node, method_name, args, _body)
          if bad_reader_name?(method_name.to_s, args)
            add_offense(node, :name, MSG_GET)
          elsif bad_writer_name?(method_name.to_s, args)
            add_offense(node, :name, MSG_SET)
          end
        end

        def bad_reader_name?(method_name, args)
          method_name.start_with?('get_') && args.to_a.empty?
        end

        def bad_writer_name?(method_name, args)
          method_name.start_with?('set_') && args.to_a.one?
        end
      end
    end
  end
end
