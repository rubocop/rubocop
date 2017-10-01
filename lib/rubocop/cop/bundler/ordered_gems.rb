# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Gems should be alphabetically sorted within groups.
      #
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
      #
      #   # good only if TreatCommentsAsGroupSeparators is true
      #   # For code quality
      #   gem 'rubocop'
      #   # For tests
      #   gem 'rspec'
      class OrderedGems < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Gems should be sorted in an alphabetical order within their '\
              'section of the Gemfile. '\
              'Gem `%s` should appear before `%s`.'.freeze

        def investigate(processed_source)
          return if processed_source.ast.nil?
          gem_declarations(processed_source.ast)
            .each_cons(2) do |previous, current|
            next unless consecutive_lines(previous, current)
            next unless case_insensitive_out_of_order?(
              gem_name(current),
              gem_name(previous)
            )
            register_offense(previous, current)
          end
        end

        private

        def case_insensitive_out_of_order?(string_a, string_b)
          string_a.downcase < string_b.downcase
        end

        def consecutive_lines(previous, current)
          first_line = get_source_range(current).first_line
          previous.source_range.last_line == first_line - 1
        end

        def register_offense(previous, current)
          add_offense(current, :expression,
                      format(MSG, gem_name(current), gem_name(previous)))
        end

        def gem_name(declaration_node)
          declaration_node.first_argument.str_content
        end

        def autocorrect(node)
          previous = previous_declaration(node)

          current_range = declaration_with_comment(node)
          previous_range = declaration_with_comment(previous)

          lambda do |corrector|
            swap_range(corrector, current_range, previous_range)
          end
        end

        def declaration_with_comment(node)
          buffer = processed_source.buffer
          begin_pos = get_source_range(node).begin_pos
          end_line = buffer.line_for_position(node.loc.expression.end_pos)
          end_pos = buffer.line_range(end_line).end_pos
          Parser::Source::Range.new(buffer, begin_pos, end_pos)
        end

        def swap_range(corrector, range1, range2)
          src1 = range1.source
          src2 = range2.source
          corrector.replace(range1, src2)
          corrector.replace(range2, src1)
        end

        def previous_declaration(node)
          declarations = gem_declarations(processed_source.ast)
          node_index = declarations.find_index(node)
          declarations.to_a[node_index - 1]
        end

        def get_source_range(node)
          unless cop_config['TreatCommentsAsGroupSeparators']
            first_comment = processed_source.ast_with_comments[node].first
            return first_comment.loc.expression unless first_comment.nil?
          end
          node.source_range
        end

        def_node_search :gem_declarations, <<-PATTERN
          (:send nil? :gem ...)
        PATTERN
      end
    end
  end
end
