# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the number of statements of the method
      # exceeds some maximum value.
      # The maximum allowed length is configurable.
      class PerceivedMethodLength < Cop
        MSG = 'Method has too many statements. [%<length>d/%<max>d]'

        def on_def(node)
          check_code_statements(node)
        end

        def on_block(node)
          return unless node.send_node.method_name == :define_method

          check_code_statements(node)
        end

        def check_code_statements(node)
          @statements = 0
          return unless count_statements(node.body) > max_statements

          location = node.casgn_type? ? :name : :expression

          add_offense(node, location: location, message: message(@statements))
        end

        private

        def max_statements
          cop_config['Max']
        end

        def message(length)
          format(MSG, length: length, max: max_statements)
        end

        def count_statements(node)
          return 0 unless node

          if compound_statement?(node)
            node.node_parts.each(&method(:count))
          else
            count(node)
          end

          @statements
        end

        def count(node)
          @statements += 1

          count_statements(node.body) if body?(node)
        end

        def compound_statement?(node)
          node.begin_type? || node.kwbegin_type?
        end

        def body?(node)
          node.respond_to?(:body)
        end
      end
    end
  end
end
