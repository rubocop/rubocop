# frozen_string_literal: true

module RuboCop
  # Extracts top description lines from source code and builds hash
  # used to update config/defauly.yml.
  class DescriptionExtractor
    def initialize(yardocs)
      @code_objects = yardocs.map(&CodeObject.public_method(:new))
    end

    def to_h
      code_objects
        .select(&:cop?)
        .map(&:configuration)
        .reduce(:merge)
    end

    private

    attr_reader :code_objects

    # Decorator of a YARD code object for working with documented cops
    class CodeObject
      def initialize(yardoc)
        @yardoc = yardoc
      end

      # Test if the YARD code object documents a concrete cop class
      #
      # @return [Boolean]
      def cop?
        class_documentation? && inherits_from_cop?
      end

      # Configuration for the documented cop that would live in default.yml
      #
      # @return [Hash]
      def configuration
        { cop_name => { 'Description' => description } }
      end

      private

      attr_reader :yardoc

      def cop_name
        constant.cop_name
      end

      def description
        yardoc.docstring.split("\n\n").first.to_s
      end

      def class_documentation?
        yardoc.type.equal?(:class)
      end

      def inherits_from_cop?
        constant.respond_to?(:cop_name)
      end

      def constant
        Object.const_get(yardoc.to_s)
      end
    end
  end
end
