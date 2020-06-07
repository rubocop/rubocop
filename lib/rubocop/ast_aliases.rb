# frozen_string_literal: true

# These aliases are for compatibility.
module RuboCop
  NodePattern = AST::NodePattern
  ProcessedSource = AST::ProcessedSource
  Token = AST::Token

  if AST.const_defined? :FastArray
    FastArray = AST::FastArray
  else
    # FastArray represents a frozen `Array` with fast lookup
    # using `include?`.
    # Like `Set`, the case equality `===` is an alias for `include?`
    #
    #     FOO = FastArray[:hello, :world]
    #     FOO.include?(:hello) # => true, quickly
    #
    #     case bar
    #     when FOO # Note: no splat
    #       # decided quickly
    #     # ...
    class FastArray < ::Array
      # Defines a function `FastArray(list)` similar to `Array(list)`
      module Function
        def FastArray(list) # rubocop:disable Naming/MethodName
          RuboCop::FastArray.new(list)
        end
      end

      attr_reader :to_set

      def initialize(ary)
        raise ArgumentError, 'Must be initialized with an array' unless ary.is_a?(Array)

        super
        freeze
      end

      def self.[](*values)
        new(values)
      end

      def freeze
        @to_set ||= Set.new(self).freeze
        super
      end

      # Return self, not a newly allocated FastArray
      def to_a
        self
      end

      def include?(value)
        @to_set.include?(value)
      end

      alias === include?
    end
  end
end
