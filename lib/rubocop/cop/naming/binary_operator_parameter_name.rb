# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Makes sure that certain binary operator methods have their
      # sole parameter named `other`.
      #
      # @example
      #
      #   # bad
      #   def +(amount); end
      #
      #   # good
      #   def +(other); end
      class BinaryOperatorParameterName < Base
        extend AutoCorrector

        MSG = 'When defining the `%<opr>s` operator, name its argument `other`.'

        OP_LIKE_METHODS = %i[eql? equal?].freeze
        EXCLUDED = %i[+@ -@ [] []= << === ` =~].freeze

        # @!method op_method_candidate?(node)
        def_node_matcher :op_method_candidate?, <<~PATTERN
          (def [#op_method? $_] (args $(arg [!:other !:_other])) _)
        PATTERN

        def on_def(node)
          op_method_candidate?(node) do |name, arg|
            add_offense(arg, message: format(MSG, opr: name)) do |corrector|
              corrector.replace(arg, 'other')
              node.each_descendant(:lvar, :lvasgn) do |lvar|
                lvar_location = lvar.loc.name
                next unless lvar_location.source == arg.source
                next if shadowed?(lvar, arg.source, node)

                corrector.replace(lvar_location, 'other')
              end
            end
          end
        end

        private

        # A reference is shadowed when an enclosing block within the method redeclares the
        # parameter name (as a block parameter or block-local). Such a reference points to
        # the block's variable, not the operator's parameter, so it must not be renamed.
        def shadowed?(node, name, def_node)
          node.each_ancestor(:block).any? do |block|
            def_node.source_range.contains?(block.source_range) && redeclares?(block, name)
          end
        end

        def redeclares?(block, name)
          block.arguments.any? do |argument|
            argument.respond_to?(:name) && argument.name.to_s == name
          end
        end

        def op_method?(name)
          return false if EXCLUDED.include?(name)

          !/\A[[:word:]]/.match?(name) || OP_LIKE_METHODS.include?(name)
        end
      end
    end
  end
end
