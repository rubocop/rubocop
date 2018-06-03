# frozen_string_literal: true

require 'jaro_winkler'

module RuboCop
  # This module provides approximate string matching methods.
  module StringUtil
    module_function

    def similarity(string_a, string_b)
      JaroWinkler.distance(string_a.to_s, string_b.to_s)
    end
  end
end
