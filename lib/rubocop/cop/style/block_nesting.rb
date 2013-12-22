# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for excessive nesting of conditional and looping
      # constructs. Despite the cop's name, blocks are not considered as a
      # extra level of nesting.
      #
      # The maximum level of nesting allowed is configurable.
      class BlockNesting < Cop
        include ConfigurableMax

        NESTING_BLOCKS = [:case, :if, :while, :while_post, :until, :until_post,
                          :for, :resbody]

        def investigate(processed_source)
          return unless processed_source.ast
          max = cop_config['Max']
          check_nesting_level(processed_source.ast, max, 0)
        end

        private

        def check_nesting_level(node, max, current_level)
          if NESTING_BLOCKS.include?(node.type)
            unless node.loc.respond_to?(:keyword) &&
                node.loc.keyword.is?('elsif')
              current_level += 1
            end
            if current_level == max + 1
              add_offence(node, :expression, message(max)) do
                self.max = current_level
              end
              return
            end
          end
          node.children.each do |child|
            if child.is_a?(Parser::AST::Node)
              check_nesting_level(child, max, current_level)
            end
          end
        end

        def message(max)
          "Avoid more than #{max} levels of block nesting."
        end
      end
    end
  end
end
