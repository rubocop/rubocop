# frozen_string_literal: true

# Extensions to the core Hash class
class Hash
  unless method_defined?(:slice)
    # Adds `Hash#slice` for Ruby 2.4.
    # Returns a hash containing a subset of keys. If a given key is not
    # in the hash, it will not be returned.
    #
    # @return [Hash] hash containing only the keys given.
    #
    # @example
    #   { one: 1, two: 2 }.slice(:two, :three) #=> { two: 2 }
    def slice(*keys)
      h = {}
      keys.each { |k| h[k] = self[k] if key?(k) }
      h
    end
  end
end
