# frozen_string_literal: true
module RuboCop
  module Cop
    module Bundler
      # Gems in consecutive lines should be alphabetically sorted
      # @example
      #   # bad
      #   gem 'rubocop'
      #   gem 'rspec'
      #
      #   # good
      #   gem 'rspec'
      #   gem 'rubocop'
      #
      #   # good
      #   gem 'rubocop'
      #
      #   gem 'rspec'
      class OrderedGems < Cop
        MSG = 'Gem `%s` should appear before `%s` in their gem group.'.freeze
        def investigate(processed_source)
          return if processed_source.ast.nil?
          gem_declarations(processed_source.ast)
            .each_cons(2) do |previous, current|
            next unless consecutive_lines(previous, current)
            next unless current.children[2].children.first.to_s <
                        previous.children[2].children.first.to_s
            register_offense(previous, current)
          end
        end

        def consecutive_lines(previous, current)
          previous.source_range.last_line == current.source_range.first_line - 1
        end

        def register_offense(previous, current)
          add_offense(
            current,
            current.source_range,
            format(
              MSG,
              current.children[2].children.first,
              previous.children[2].children.first
            )
          )
        end

        def_node_search :gem_declarations, <<-PATTERN
          (:send, nil, :gem, ...)
        PATTERN
      end
    end
  end
end
