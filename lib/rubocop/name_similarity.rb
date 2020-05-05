# frozen_string_literal: true

module RuboCop
  # Common functionality for finding names that are similar to a given name.
  module NameSimilarity
    module_function

    MINIMUM_SIMILARITY_TO_SUGGEST = 0.9

    def find_similar_name(target_name, names)
      names = names.dup
      names.delete(target_name)

      spell_checker = DidYouMean::SpellChecker.new(dictionary: names)
      similar_names = spell_checker.correct(target_name)

      similar_names.first
    end
  end
end
