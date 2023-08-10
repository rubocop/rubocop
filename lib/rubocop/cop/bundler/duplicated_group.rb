# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # A Gem group, or a set of groups, should be listed only once in a Gemfile.
      #
      # @example
      #   # bad
      #   group :development do
      #     gem 'rubocop'
      #   end
      #
      #   group :development do
      #     gem 'rubocop-rails'
      #   end
      #
      #   # bad (same set of groups declared twice)
      #   group :development, :test do
      #     gem 'rubocop'
      #   end
      #
      #   group :test, :development do
      #     gem 'rspec'
      #   end
      #
      #   # good
      #   group :development do
      #     gem 'rubocop'
      #   end
      #
      #   group :development, :test do
      #     gem 'rspec'
      #   end
      #
      #   # good
      #   gem 'rubocop', groups: [:development, :test]
      #   gem 'rspec', groups: [:development, :test]
      #
      class DuplicatedGroup < Base
        include RangeHelp

        MSG = 'Gem group `%<group_name>s` already defined on line ' \
              '%<line_of_first_occurrence>d of the Gemfile.'

        # @!method group_declarations(node)
        def_node_search :group_declarations, '(send nil? :group ...)'

        def on_new_investigation
          return if processed_source.blank?

          duplicated_group_nodes.each do |nodes|
            nodes[1..].each do |node|
              group_name = node.arguments.map(&:source).join(', ')

              register_offense(node, group_name, nodes.first.first_line)
            end
          end
        end

        private

        def duplicated_group_nodes
          groups = group_declarations(processed_source.ast).group_by do |node|
            group_attributes(node).sort
          end

          groups.values.select { |nodes| nodes.size > 1 }
        end

        def register_offense(node, group_name, line_of_first_occurrence)
          line_range = node.loc.column...node.loc.last_column
          offense_location = source_range(processed_source.buffer, node.first_line, line_range)
          message = format(
            MSG,
            group_name: group_name,
            line_of_first_occurrence: line_of_first_occurrence
          )
          add_offense(offense_location, message: message)
        end

        def group_attributes(node)
          node.arguments.map do |argument|
            if argument.hash_type?
              argument.pairs.map(&:source).sort.join(', ')
            else
              argument.value.to_s
            end
          end
        end
      end
    end
  end
end
