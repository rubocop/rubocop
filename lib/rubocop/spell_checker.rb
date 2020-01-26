# frozen_string_literal: true

module RuboCop
  # Gem `did_you_mean` is shipped with Ruby 2.3 and later and is automatically
  # required when a Ruby process starts up.
  #
  # But it may be disabled with command-line option `--disable=did_you_mean`.
  # In that case we use a stub that returns no corrections.
  class SpellChecker
    # Suggests corrections from a list of known words. In the result, more
    # likely corrections are listed earlier.
    def self.suggest(name, from:)
      if defined?(DidYouMean::SpellChecker)
        DidYouMean::SpellChecker.new(dictionary: from).correct(name)
      else
        []
      end
    end
  end
end
