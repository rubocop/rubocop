# frozen_string_literal: true

module RuboCop
  # Caps how many offenses each cop gets to report.
  #
  # Counted across a whole run rather than per file, since a cop that fires a
  # handful of times in every file is exactly the one worth capping. Offenses
  # have to be offered in a stable order (files in the order they are
  # reported) for the same ones to survive every time.
  # @api private
  class OffenseLimit
    attr_reader :max

    def initialize(max)
      @max = max
      @offered = Hash.new(0)
    end

    # @return [Array<Cop::Offense>] the offenses still within their cop's limit
    def filter(offenses)
      offenses.select { |offense| (@offered[offense.cop_name] += 1) <= @max }
    end

    # @return [Hash{String => Integer}] how many offenses each cop had left out,
    #   sorted by cop name
    def elided_per_cop
      @offered.filter_map { |cop, count| [cop, count - @max] if count > @max }.sort.to_h
    end
  end
end
