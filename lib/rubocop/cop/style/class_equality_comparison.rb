# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the use of `Object#instance_of?` instead of class comparison
      # for equality.
      #
      # @example
      #   # bad
      #   var.class == Date
      #   var.class.equal?(Date)
      #   var.class.eql?(Date)
      #   var.class.name == 'Date'
      #
      #   # good
      #   var.instance_of?(Date)
      #
      class ClassEqualityComparison < Base
        include RangeHelp
        include IgnoredMethods
        extend AutoCorrector

        MSG = 'Use `Object.instance_of?` instead of comparing classes.'

        RESTRICT_ON_SEND = %i[== equal? eql?].freeze

        def_node_matcher :class_comparison_candidate?, <<~PATTERN
          (send
            {$(send _ :class) (send $(send _ :class) :name)}
            {:== :equal? :eql?} $_)
        PATTERN

        def on_send(node)
          def_node = node.each_ancestor(:def, :defs).first
          return if def_node && ignored_method?(def_node.method_name)

          class_comparison_candidate?(node) do |receiver_node, class_node|
            range = range_between(receiver_node.loc.selector.begin_pos, node.source_range.end_pos)

            add_offense(range) do |corrector|
              corrector.replace(range, "instance_of?(#{class_node.source})")
            end
          end
        end
      end
    end
  end
end
