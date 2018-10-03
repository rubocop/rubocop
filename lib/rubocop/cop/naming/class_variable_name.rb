# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sur that variable used to store Classes are not
      # named clazz
      #
      # @example
      #   # bad
      #   def do_something_with_class(clazz)
      #   end
      #
      #   # bad
      #   classes.map { |clazz| puts clazz.name }
      #
      #   # bad
      #   clazz = Array
      #
      #   # good
      #   def do_something_with_class(klass)
      #   end
      #
      #   # good
      #   classes.map { |klass| puts klass.name }
      #
      #   # good
      #   klass = Array
      class ClassVariableName < Cop
        MSG = 'Use `klass` instead of `clazz`.'.freeze

        def on_lvasgn(node)
          name, = *node
          return unless name

          check_name(node, name)
        end
        alias on_ivasgn    on_lvasgn
        alias on_cvasgn    on_lvasgn
        alias on_arg       on_lvasgn
        alias on_optarg    on_lvasgn
        alias on_restarg   on_lvasgn
        alias on_kwoptarg  on_lvasgn
        alias on_kwarg     on_lvasgn
        alias on_kwrestarg on_lvasgn
        alias on_blockarg  on_lvasgn

        private

        def check_name(node, name)
          add_offense(node) if invalid_name?(name)
        end

        def invalid_name?(name)
          name.match(/clazz/i)
        end
      end
    end
  end
end
