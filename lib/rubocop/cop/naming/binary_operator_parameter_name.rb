# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that certain binary operator methods have their
      # sole  parameter named `other`.
      #
      # @example
      #
      #   # bad
      #   def +(amount); end
      #
      #   # good
      #   def +(other); end
      class BinaryOperatorParameterName < Cop
        MSG = 'When defining the `%s` operator, ' \
              'name its argument `other`.'.freeze

        OP_LIKE_METHODS = %i[eql? equal?].freeze
        BLACKLISTED = %i[+@ -@ [] []= << `].freeze

        def_node_matcher :op_method_candidate?, <<-PATTERN
          (def [#op_method? $_] (args $(arg [!:other !:_other])) _)
        PATTERN

        def on_def(node)
          op_method_candidate?(node) do |name, arg|
            add_offense(arg, message: format(MSG, name))
          end
        end

        private

        def op_method?(name)
          return false if BLACKLISTED.include?(name)
          name !~ /\A\w/ || OP_LIKE_METHODS.include?(name)
        end
      end
    end
  end
end
