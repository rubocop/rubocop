module RuboCop
  module Cop
    module Metrics
      class SingleLineComplexity < Base

        MSG = 'Assignment Branch Condition size too high for line %<line>d. [%<complexity>d/%<max>d]'

        def on_new_investigation
          return unless (root = processed_source.ast)

          root_nodes_per_line = map_nodes_to_lines(root)

          root_nodes_per_line.each do |line, nodes|
            abc_score, _ = abc_score_for_nodes(nodes)

            add_offense(nodes.first, message: format(MSG, line: line, complexity: abc_score, max: max_score_allowed)) if abc_score > max_score_allowed
          end
        end

        private

        def abc_score_for_nodes(nodes)
          scores = nodes.map do |node|
            calculator = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.new(node)
            calculator.calculate
          end

          sum_complexity_scores(scores)
        end

        def sum_complexity_scores(scores)
          vector_sums = []

          scores.each do |score|
            _, vector = score

            # Parse and sum vector components
            vector_values = vector[1..-2].split(',').map(&:to_f) # Remove < > and split by comma
            vector_values.each_with_index do |value, i|
              vector_sums[i] = (vector_sums[i] || 0) + value
            end
          end

          total_score = Math.sqrt(vector_sums.sum { |sum| sum**2 }).round(2)

          [total_score, "<#{vector_sums.join(', ')}>"]
        end

        def map_nodes_to_lines(root)
          nodes_per_line = {}

          root.each_node do |child|
            next unless child.source_range

            line_range = child.source_range.first_line..child.source_range.last_line

            # Skip nodes that span multiple lines
            next if line_range.size > 1

            line_range.each do |line|
              nodes_per_line[line] ||= []
              nodes_per_line[line] << child
            end
          end

          # Filter nodes to only include root nodes for each line
          nodes_per_line.transform_values do |nodes|
            nodes.reject do |node|
              # Reject nodes where the parent is also in the list of nodes for this line
              nodes.include?(node.parent)
            end
          end
        end

        def calculate_abc(nodes)
          nodes.sum do |node|
            calculator = Utils::AbcSizeCalculator.new(node)
            calculator.calculate
          end
        end

        def max_score_allowed
          cop_config['Max'] || 10
        end
      end
    end
  end
end
