# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  # Common functionality for finding names that are similar to a given name.
  module NameSimilarity
    MINIMUM_SIMILARITY_TO_SUGGEST = 0.9

    def find_similar_name(target_name, scope)
      names = collect_variable_like_names(scope)
      names.delete(target_name)

      scores = names.each_with_object({}) do |name, hash|
        score = StringUtil.similarity(target_name, name)
        hash[name] = score if score >= MINIMUM_SIMILARITY_TO_SUGGEST
      end

      most_similar_name, _max_score = scores.max_by { |_, score| score }
      most_similar_name
    end
  end
end
