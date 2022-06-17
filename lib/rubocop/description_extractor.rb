# frozen_string_literal: true

module RuboCop
  # Extracts cop descriptions from YARD docstrings
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
      COP_BASE_CLASS = RuboCop::Cop::Base
      # RSPEC_NAMESPACE = 'RuboCop::Cop::RSpec'

      def initialize(yardoc)
        @yardoc = yardoc
      end

      # Test if the YARD code object documents a concrete cop class
      #
      # @return [Boolean]
      def cop?
          # rspec_cop_namespace? &&
        class_documentation? &&
          cop_subclass? &&
          !abstract?
      end

      # Configuration for the documented cop that would live in default.yml
      #
      # @return [Hash]
      def configuration
        { cop_name => { 'Description' => description } }
      end

      private

      def cop_class
        Object.const_get(documented_constant)
      end

      def cop_name
        cop_class.cop_name
      end

      def description
        yardoc.docstring.split("\n\n").first.to_s
      end

      def class_documentation?
        yardoc.type.equal?(:class)
      end

      def documented_constant
        yardoc.path
      end

      def cop_subclass?
        cop_class.ancestors.include?(COP_BASE_CLASS)
      end

      def abstract?
        yardoc.tags.any? { |tag| tag.tag_name.eql?('abstract') }
      end

      attr_reader :yardoc
    end
  end
end
