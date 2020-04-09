# frozen_string_literal: true

module RuboCop
  module Cop
    # This class takes a source buffer and rewrite its source
    # based on the different correction rules supplied.
    #
    # Important!
    # The nodes modified by the corrections should be part of the
    # AST of the source_buffer.
    class Corrector
      #
      # @param source_buffer [Parser::Source::Buffer]
      # @param corrections [Array(#call)]
      #   Array of Objects that respond to #call. They will receive the
      #   corrector itself and should use its method to modify the source.
      #
      # @example
      #
      #   class AndOrCorrector
      #     def initialize(node)
      #       @node = node
      #     end
      #
      #     def call(corrector)
      #       replacement = (@node.type == :and ? '&&' : '||')
      #       corrector.replace(@node.loc.operator, replacement)
      #     end
      #   end
      #
      #   corrections = [AndOrCorrector.new(node)]
      #   corrector = Corrector.new(source_buffer, corrections)
      def initialize(source_buffer, corrections = [])
        @source_buffer = source_buffer
        raise 'source_buffer should be a Parser::Source::Buffer' unless \
          source_buffer.is_a? Parser::Source::Buffer

        @corrections = corrections
        @source_rewriter = Parser::Source::TreeRewriter.new(
          source_buffer,
          different_replacements: :raise,
          swallowed_insertions: :raise,
          crossing_deletions: :accept
        )

        @diagnostics = []
        # Don't print warnings to stderr if corrections conflict with each other
        @source_rewriter.diagnostics.consumer = lambda do |diagnostic|
          @diagnostics << diagnostic
        end
      end

      attr_reader :corrections, :diagnostics

      # Does the actual rewrite and returns string corresponding to
      # the rewritten source.
      #
      # @return [String]
      def rewrite
        @corrections.each do |correction|
          begin
            @source_rewriter.transaction do
              correction.call(self)
            end
          rescue ErrorWithAnalyzedFileLocation => e
            raise e unless e.cause.is_a?(::Parser::ClobberingError)
          end
        end

        @source_rewriter.process
      end

      # Removes the source range.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      def remove(node_or_range)
        range = to_range(node_or_range)
        @source_rewriter.remove(range)
      end

      # Inserts new code before the given source range.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [String] content
      def insert_before(node_or_range, content)
        range = to_range(node_or_range)
        # TODO: Fix Cops using bad ranges instead
        if range.end_pos > @source_buffer.source.size
          range = range.with(end_pos: @source_buffer.source.size)
        end

        @source_rewriter.insert_before(range, content)
      end

      # Inserts new code after the given source range.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [String] content
      def insert_after(node_or_range, content)
        range = to_range(node_or_range)
        @source_rewriter.insert_after(range, content)
      end

      # Wraps the given source range with the given before and after texts
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [String] before
      # @param [String] after
      def wrap(node_or_range, before, after)
        range = to_range(node_or_range)
        @source_rewriter.wrap(range, before, after)
      end

      # Replaces the code of the source range `range` with `content`.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [String] content
      def replace(node_or_range, content)
        range = to_range(node_or_range)
        @source_rewriter.replace(range, content)
      end

      # Removes `size` characters prior to the source range.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [Integer] size
      def remove_preceding(node_or_range, size)
        range = to_range(node_or_range)
        to_remove = Parser::Source::Range.new(range.source_buffer,
                                              range.begin_pos - size,
                                              range.begin_pos)
        @source_rewriter.remove(to_remove)
      end

      # Removes `size` characters from the beginning of the given range.
      # If `size` is greater than the size of `range`, the removed region can
      # overrun the end of `range`.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [Integer] size
      def remove_leading(node_or_range, size)
        range = to_range(node_or_range)
        to_remove = Parser::Source::Range.new(range.source_buffer,
                                              range.begin_pos,
                                              range.begin_pos + size)
        @source_rewriter.remove(to_remove)
      end

      # Removes `size` characters from the end of the given range.
      # If `size` is greater than the size of `range`, the removed region can
      # overrun the beginning of `range`.
      #
      # @param [Parser::Source::Range, Rubocop::AST::Node] range or node
      # @param [Integer] size
      def remove_trailing(node_or_range, size)
        range = to_range(node_or_range)
        to_remove = Parser::Source::Range.new(range.source_buffer,
                                              range.end_pos - size,
                                              range.end_pos)
        @source_rewriter.remove(to_remove)
      end

      private

      # :nodoc:
      def to_range(node_or_range)
        range = case node_or_range
                when ::RuboCop::AST::Node, ::Parser::Source::Comment
                  node_or_range.loc.expression
                when ::Parser::Source::Range
                  node_or_range
                else
                  raise TypeError,
                        'Expected a Parser::Source::Range, Comment or ' \
                        "Rubocop::AST::Node, got #{node_or_range.class}"
                end
        validate_buffer(range.source_buffer)
        range
      end

      def validate_buffer(buffer)
        return if buffer == @source_buffer

        unless buffer.is_a?(::Parser::Source::Buffer)
          # actually this should be enforced by parser gem
          raise 'Corrector expected range source buffer to be a ' \
                "Parser::Source::Buffer, but got #{buffer.class}"
        end
        raise "Correction target buffer #{buffer.object_id} " \
              "name:#{buffer.name.inspect}" \
              " is not current #{@source_buffer.object_id} " \
              "name:#{@source_buffer.name.inspect} under investigation"
      end
    end
  end
end
