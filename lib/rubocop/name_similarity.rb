# frozen_string_literal: true

module RuboCop
  # Common functionality for finding names that are similar to a given name.
  module NameSimilarity
    module_function

    def find_similar_name(target_name, names)
      similar_names = find_similar_names(target_name, names)

      similar_names.first
    end

    def find_similar_names(target_name, names)
      names = names.dup
      names.delete(target_name)

      spell_checker = DidYouMean::SpellChecker.new(dictionary: names)
      similar_names = spell_checker.correct(target_name)

      similar_names
    end
  end
end
