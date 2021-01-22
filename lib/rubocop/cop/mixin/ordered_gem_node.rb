# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for Bundler/OrderedGems and
    # Gemspec/OrderedDependencies.
    module OrderedGemNode
      private

      def get_source_range(node, comments_as_separators)
        unless comments_as_separators
          first_comment = processed_source.ast_with_comments[node].first
          return first_comment.loc.expression unless first_comment.nil?
        end
        node.source_range
      end

      def gem_canonical_name(name)
        name = name.tr('-_', '') unless cop_config['ConsiderPunctuation']
        name.downcase
      end

      def case_insensitive_out_of_order?(string_a, string_b)
        gem_canonical_name(string_a) < gem_canonical_name(string_b)
      end

      def consecutive_lines(previous, current)
        end_pos = current.source_range.first_line
        begin_pos = previous.source_range.last_line
        return true if begin_pos == end_pos - 1

        !treat_comments_as_separators && contains_only_comments?(begin_pos, end_pos - 2)
      end

      def register_offense(previous, current)
        message = format(
          self.class::MSG,
          previous: gem_name(current),
          current: gem_name(previous)
        )
        add_offense(current, message: message)
      end

      def gem_name(declaration_node)
        gem_node = declaration_node.first_argument

        find_gem_name(gem_node)
      end

      def find_gem_name(gem_node)
        return gem_node.str_content if gem_node.str_type?

        find_gem_name(gem_node.receiver)
      end

      def treat_comments_as_separators
        cop_config['TreatCommentsAsGroupSeparators']
      end

      def contains_only_comments?(begin_pos, end_pos)
        processed_source.lines[begin_pos..end_pos].all? { |line| comment_line?(line) }
      end
    end
  end
end
