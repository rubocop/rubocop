# frozen_string_literal: true

module RuboCop
  module RSpec
    # Mixin for `expect_offense` and `expect_no_offenses`
    #
    # This mixin makes it easier to specify strict offense expectations
    # in a declarative and visual fashion. Just type out the code that
    # should generate a offense, annotate code by writing '^'s
    # underneath each character that should be highlighted, and follow
    # the carets with a string (separated by a space) that is the
    # message of the offense. You can include multiple offenses in
    # one code snippet.
    #
    # @example Usage
    #
    #     expect_offense(<<-RUBY.strip_indent)
    #       a do
    #         b
    #       end.c
    #       ^^^^^ Avoid chaining a method call on a do...end block.
    #     RUBY
    #
    # @example Equivalent assertion without `expect_offense`
    #
    #     inspect_source(<<-RUBY.strip_indent)
    #       a do
    #         b
    #       end.c
    #     RUBY
    #
    #     expect(cop.offenses.size).to be(1)
    #
    #     offense = cop.offenses.first
    #     expect(offense.line).to be(3)
    #     expect(offense.column_range).to be(0...5)
    #     expect(offense.message).to eql(
    #       'Avoid chaining a method call on a do...end block.'
    #     )
    #
    # If you do not want to specify an offense then use the
    # companion method `expect_no_offenses`. This method is a much
    # simpler assertion since it just inspects the source and checks
    # that there were no offenses. The `expect_offenses` method has
    # to do more work by parsing out lines that contain carets.
    module ExpectOffense
      def expect_offense(source, file = nil)
        expected_annotations = AnnotatedSource.parse(source)

        if expected_annotations.plain_source == source
          raise 'Use expect_no_offenses to assert that no offenses are found'
        end

        inspect_source(expected_annotations.plain_source, file)
        actual_annotations =
          expected_annotations.with_offense_annotations(cop.offenses)
        expect(actual_annotations.to_s).to eq(expected_annotations.to_s)
      end

      def expect_no_offenses(source, file = nil)
        inspect_source(source, file)

        expect(cop.offenses).to be_empty
      end

      # Parsed representation of code annotated with the `^^^ Message` style
      class AnnotatedSource
        ANNOTATION_PATTERN = /\A\s*\^+ /.freeze

        # @param annotated_source [String] string passed to the matchers
        #
        # Separates annotation lines from source lines. Tracks the real
        # source line number that each annotation corresponds to.
        #
        # @return [AnnotatedSource]
        def self.parse(annotated_source)
          source      = []
          annotations = []

          annotated_source.each_line do |source_line|
            if source_line =~ ANNOTATION_PATTERN
              annotations << [source.size, source_line]
            else
              source << source_line
            end
          end

          new(source, annotations)
        end

        # @param lines [Array<String>]
        # @param annotations [Array<(Integer, String)>]
        #   each entry is the annotated line number and the annotation text
        #
        # @note annotations are sorted so that reconstructing the annotation
        #   text via {#to_s} is deterministic
        def initialize(lines, annotations)
          @lines       = lines.freeze
          @annotations = annotations.sort.freeze
        end

        # Construct annotated source string (like what we parse)
        #
        # Reconstruct a deterministic annotated source string. This is
        # useful for eliminating semantically irrelevant annotation
        # ordering differences.
        #
        # @example standardization
        #
        #     source1 = AnnotatedSource.parse(<<-RUBY)
        #     line1
        #     ^ Annotation 1
        #      ^^ Annotation 2
        #     RUBY
        #
        #     source2 = AnnotatedSource.parse(<<-RUBY)
        #     line1
        #      ^^ Annotation 2
        #     ^ Annotation 1
        #     RUBY
        #
        #     source1.to_s == source2.to_s # => true
        #
        # @return [String]
        def to_s
          reconstructed = lines.dup

          annotations.reverse_each do |line_number, annotation|
            reconstructed.insert(line_number, annotation)
          end

          reconstructed.join
        end

        # Return the plain source code without annotations
        #
        # @return [String]
        def plain_source
          lines.join
        end

        # Annotate the source code with the RuboCop offenses provided
        #
        # @param offenses [Array<RuboCop::Cop::Offense>]
        #
        # @return [self]
        def with_offense_annotations(offenses)
          offense_annotations =
            offenses.map do |offense|
              indent     = ' ' * offense.column
              carets     = '^' * offense.column_length

              [offense.line, "#{indent}#{carets} #{offense.message}\n"]
            end

          self.class.new(lines, offense_annotations)
        end

        private

        attr_reader :lines, :annotations
      end
    end
  end
end
