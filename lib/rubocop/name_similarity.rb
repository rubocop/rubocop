# frozen_string_literal: true

module RuboCop
  # Common functionality for finding names that are similar to a given name.
  module NameSimilarity
    def find_similar_name(target_name, scope)
      names = collect_variable_like_names(scope)

      SpellChecker.suggest(target_name, from: names).first
    end
  end
end
